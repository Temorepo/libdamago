package com.whirled.contrib.simplegame.debug
{
import aduros.util.F;

import com.threerings.ui.DisplayUtils;
import com.threerings.ui.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimpleGame;

import flash.display.Sprite;
import flash.events.MouseEvent;

[SWF(width="500", height="500", frameRate="30")]
public class SimpleGameRunner extends Sprite
{
    public function SimpleGameRunner (mode :AppMode = null)
    {
        addChild(_bottomLayer);
        addChild(_topLayer);
        if (mode != null) {
            queueAppMode(mode);
        }
    }

    public function queueAppMode (mode :AppMode) :void
    {
        _queuedModes.push(mode);
        if (_currentMode == null) {
            runNextMode();
        }
    }

    protected function runNextMode () :void
    {
        if (_queuedModes.length == 0) {
            return;
        }
        var mode :AppMode = _queuedModes.pop() as AppMode;
        _currentMode = mode;

        var framerate :FramerateView = new FramerateView();
        framerate.x = 100;
        mode.addSceneObject(framerate);
        var game :SimpleGame = new SimpleGame();
        game.ctx.mainLoop.pushMode(mode);
        game.run(_bottomLayer);

        var closeButton :SimpleTextButton = new SimpleTextButton("Close/Next");
        _topLayer.addChild(closeButton);
        closeButton.x = this.stage.stageWidth - closeButton.width;
        closeButton.addEventListener(MouseEvent.CLICK, F.justOnce(function() :void {
                game.shutdown();
                DisplayUtils.detach(closeButton);
                _currentMode = null;
                runNextMode();
            }));
    }

    protected var _currentMode :AppMode;
    protected var _queuedModes :Array = [];
    protected var _topLayer :Sprite = new Sprite();
    protected var _bottomLayer :Sprite = new Sprite();

}
}