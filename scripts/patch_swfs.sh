#!/usr/bin/env bash
# Batch-patch all SWFs with ExternalInterface bridge code.
# Prepends getVar/setVar callbacks to frame_1/DoAction in each SWF.
#
# Usage: ./scripts/patch_swfs.sh
# Requires: Java, JPEXS FFDec at ~/Downloads/ffdec/ffdec-cli.jar

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FFDEC_JAR="$HOME/Downloads/ffdec/ffdec-cli.jar"
SRC_DIR="$REPO_ROOT/extracted_media"
OUT_DIR="$REPO_ROOT/poc/swf"
TMPDIR="$(mktemp -d)"

trap 'rm -rf "$TMPDIR"' EXIT

if [ ! -f "$FFDEC_JAR" ]; then
  echo "ERROR: FFDec not found at $FFDEC_JAR"
  exit 1
fi

# Bridge code to prepend
cat > "$TMPDIR/bridge.as" << 'BRIDGE'
if(flash.external.ExternalInterface.available)
{
   // Capture gFlashRequest writes so they survive until the next JS poll.
   // SWFs may overwrite gFlashRequest every frame; without this, the 100ms
   // polling interval misses single-frame requests.
   var _pendingRequest = "";
   _root.watch("gFlashRequest", function(prop, oldVal, newVal)
   {
      if(newVal != undefined && newVal != "" && String(newVal) != "undefined")
      {
         _pendingRequest = String(newVal);
      }
      return newVal;
   });
   flash.external.ExternalInterface.addCallback("setVar", null, function(name, value)
   {
      var parts = name.split(".");
      var obj = _root;
      var i = 0;
      while(i < parts.length - 1)
      {
         obj = obj[parts[i]];
         if(obj == undefined) return;
         i++;
      }
      var prop = parts[parts.length - 1];
      if(value === "true") value = true;
      else if(value === "false") value = false;
      else if(!isNaN(Number(value)) && value !== "") value = Number(value);
      obj[prop] = value;
   });
   flash.external.ExternalInterface.addCallback("getVar", null, function(name)
   {
      return String(_root[name]);
   });
   flash.external.ExternalInterface.addCallback("getPolledState", null, function()
   {
      var gs = (_root.gStat != undefined) ? String(_root.gStat) : "";
      // Read from _pendingRequest (populated by watch callback) so we never
      // miss a request that was overwritten between polls.
      var gr = _pendingRequest;
      _pendingRequest = "";
      // Also check the live variable in case watch didn't fire (e.g. Ruffle quirk)
      if(gr == "" || gr == "undefined")
      {
         gr = (_root.gFlashRequest != undefined) ? String(_root.gFlashRequest) : "";
      }
      if(gr != "" && gr != "undefined")
      {
         _root.gFlashRequest = "";
      }
      var gc = (_root.gClickToContinue != undefined) ? String(_root.gClickToContinue) : "";
      return gs + "\x01" + gr + "\x01" + gc;
   });
   flash.external.ExternalInterface.addCallback("gotoFrame", null, function(n)
   {
      _root.gotoAndStop(Number(n));
   });
   flash.external.ExternalInterface.addCallback("callFrame", null, function(n)
   {
      _root.gotoAndPlay(Number(n));
   });
   flash.external.ExternalInterface.addCallback("processChunkHelp", null, function()
   {
      if(typeof _root.readChunk == "function" && _root.chunkHelp != undefined && _root.chunkHelp.indexOf("/") > -1)
      {
         _root.readChunk();
         _root.loadHelp(_root.fetchHelp);
         if(eval("/help/0") != undefined)
         {
            eval("/help/0").gotoAndStop(_root.frameHelp);
         }
         _root.chunkHelp = "";
      }
   });
   flash.external.ExternalInterface.addCallback("processChunkPage", null, function()
   {
      if(typeof _root.readChunk == "function" && _root.chunkPage != undefined && _root.chunkPage.indexOf("/") > -1)
      {
         _root.readChunk();
         if(Math.floor(_root.fetchPage) >= 1 && Math.floor(_root.fetchPage) <= 80)
         {
            _root.loadPage(_root.fetchPage);
            if(eval("/page/0") != undefined)
            {
               eval("/page/0").gotoAndStop(_root.framePage);
            }
         }
         _root.chunkPage = "";
      }
   });
   flash.external.ExternalInterface.addCallback("enableStandaloneMode", null, function()
   {
      // Tokens SWF: its initFlashEvents() overwrites pNum/pStat/pData with
      // defaults, and with DirectorInControl=0 the SWF never sends
      // gFlashRequest for navigation (playWaitLOOP uses clickToContinue
      // instead). Keep DirectorInControl=1 and set up g-prefix mouse
      // listeners that the Tokens ActionScript reads.
      if(_root.puzzleName == "Tokens")
      {
         var mIdle = new Object();
         mIdle.onMouseMove = function()
         {
            _root.gIdleX = Math.round(_root._xmouse);
            _root.gIdleY = Math.round(_root._ymouse);
         };
         Mouse.addListener(mIdle);
         var mDown = new Object();
         mDown.onMouseDown = function()
         {
            _root.gIdleX = Math.round(_root._xmouse);
            _root.gIdleY = Math.round(_root._ymouse);
            _root.gMouseDown = 1;
         };
         Mouse.addListener(mDown);
         var mUp = new Object();
         mUp.onMouseUp = function()
         {
            _root.gIdleX = Math.round(_root._xmouse);
            _root.gIdleY = Math.round(_root._ymouse);
            _root.gMouseDown = 0;
            _root.gMouseUp = 1;
            if(_root.timeClick < _root.lastClick + 5)
            {
               _root.gMouseUp = 2;
            }
            _root.lastClick = _root.timeClick;
         };
         Mouse.addListener(mUp);
         var kUp = new Object();
         kUp.onKeyUp = function()
         {
            _root.gKeyDown = Key.getAscii();
         };
         Key.addListener(kUp);
         // Double-click timer (same as initFlashEvents)
         _root.BG.attachMovie("flash-timer","timer",13);
         _root.timeClick = 0;
         _root.lastClick = 0;
         // Do NOT set DirectorInControl=0 — the SWF needs it to be 1
         // so playWaitLOOP sends gFlashRequest instead of looping.
         return;
      }
      if(typeof _root.initFlashEvents == "function")
      {
         _root.initFlashEvents(0, 0);
      }
      else
      {
         var mw = Stage.width;
         var mh = Stage.height;
         _root.pMouseChunk = Math.round(_root._xmouse) + "," + Math.round(_root._ymouse) + ",";
         _root.pIdleX = Math.round(_root._xmouse);
         _root.pIdleY = Math.round(_root._ymouse);
         _root.pLastIdleX = _root.pIdleX;
         _root.pLastIdleY = _root.pIdleY;
         var mIdle = new Object();
         mIdle.onMouseMove = function()
         {
            var cx = Math.round(_root._xmouse);
            var cy = Math.round(_root._ymouse);
            if(cx < 0) cx = 0;
            if(cx > mw) cx = mw;
            if(cy < 0) cy = 0;
            if(cy > mh) cy = mh;
            _root.pIdleX = cx;
            _root.pIdleY = cy;
            if(cx != _root.pLastIdleX || cy != _root.pLastIdleY || _root.pMouseChunk == "")
            {
               _root.pMouseChunk = cx + "," + cy + "," + _root.pMouseChunk;
               if(_root.pMouseChunk.length > 200)
               {
                  _root.pMouseChunk = cx + "," + cy + ",";
               }
               _root.pLastIdleX = cx;
               _root.pLastIdleY = cy;
            }
            _root.pShiftKey = Number(Key.isDown(16));
            _root.gIdleX = cx;
            _root.gIdleY = cy;
            _root.gShiftKey = Number(Key.isDown(16));
         };
         Mouse.addListener(mIdle);
         var mDown = new Object();
         mDown.onMouseDown = function()
         {
            _root.pMouseDown = 1;
            _root.pMouseUp = 0;
            _root.pShiftKey = Number(Key.isDown(16));
            _root.gMouseDown = 1;
            _root.gMouseUp = 0;
         };
         Mouse.addListener(mDown);
         var mUp = new Object();
         mUp.onMouseUp = function()
         {
            _root.pMouseDown = 0;
            _root.pMouseUp = 1;
            _root.pShiftKey = Number(Key.isDown(16));
            _root.gMouseDown = 0;
            _root.gMouseUp = 1;
         };
         Mouse.addListener(mUp);
         var kDown = new Object();
         kDown.onKeyDown = function()
         {
            _root.pKeyDown = Key.getAscii();
            _root.pKeyCode = Key.getCode();
            _root.pKeyUp = 0;
            if(_root.pKeyDown > 0)
            {
               _root.pKeyChunk = _root.pKeyChunk + _root.pKeyDown + ",";
            }
            _root.gKeyDown = Key.getAscii();
            _root.gKeyUp = 0;
         };
         Key.addListener(kDown);
         var kUp = new Object();
         kUp.onKeyUp = function()
         {
            _root.pKeyUp = 1;
            _root.pKeyDown = 0;
            _root.pKeyCode = 0;
            _root.gKeyUp = 1;
            _root.gKeyDown = 0;
         };
         Key.addListener(kUp);
      }
      _root.DirectorInControl = 0;
   });
}
BRIDGE

mkdir -p "$OUT_DIR"

total=0
patched=0
failed=0
skipped=0

for swf in "$SRC_DIR"/*.swf; do
  filename="$(basename "$swf")"
  total=$((total + 1))

  # Export scripts to find frame_1/DoAction
  export_dir="$TMPDIR/export_$total"
  mkdir -p "$export_dir"

  java -jar "$FFDEC_JAR" -export script "$export_dir" "$swf" > /dev/null 2>&1 || true

  doaction="$export_dir/scripts/frame_1/DoAction.as"
  if [ ! -f "$doaction" ]; then
    # No frame_1/DoAction — copy unpatched
    echo "SKIP (no DoAction): $filename"
    cp "$swf" "$OUT_DIR/$filename"
    skipped=$((skipped + 1))
    continue
  fi

  # Combine bridge + original DoAction
  combined="$TMPDIR/combined_$total.as"
  cat "$TMPDIR/bridge.as" "$doaction" > "$combined"

  # Replace DoAction in SWF
  out_swf="$OUT_DIR/$filename"
  if java -jar "$FFDEC_JAR" -replace "$swf" "$out_swf" "/frame_1/DoAction" "$combined" 2>&1 | grep -q "^Replace"; then
    echo "OK: $filename"
    patched=$((patched + 1))
  else
    echo "FAIL: $filename"
    cp "$swf" "$OUT_DIR/$filename"
    failed=$((failed + 1))
  fi
done

echo ""
echo "Done. Total: $total | Patched: $patched | Skipped: $skipped | Failed: $failed"
echo "Output: $OUT_DIR"
