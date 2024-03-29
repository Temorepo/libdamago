// Flashbang - a framework for creating Flash games
// http://code.google.com/p/flashbang/
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.threerings.flashbang.pushbutton {

import com.threerings.flashbang.components.AlphaComponent;
import com.threerings.flashbang.components.BoundsComponent;
import com.threerings.flashbang.components.RotationComponent;
import com.threerings.flashbang.components.ScaleComponent;
import com.threerings.flashbang.components.SceneComponent;
import com.threerings.flashbang.components.VisibleComponent;
import com.threerings.flashbang.GameObjectEntity;

import flash.display.DisplayObject;
import com.threerings.flashbang.GameObjectEntity;

public class EntitySceneObject extends GameObjectEntity
    implements AlphaComponent, BoundsComponent, ScaleComponent, SceneComponent, VisibleComponent,
               RotationComponent
{

    public function EntitySceneObject (name :String = null)
    {
        super(name);
    }


    public function get displayObject () :DisplayObject
    {
        return null;
    }

    public function get alpha () :Number
    {
        return this.displayObject.alpha;
    }

    public function set alpha (val :Number) :void
    {
        this.displayObject.alpha = val;
    }

    public function get x () :Number
    {
        return this.displayObject.x;
    }

    public function set x (val :Number) :void
    {
        this.displayObject.x = val;
    }

    public function get y () :Number
    {
        return this.displayObject.y;
    }

    public function set y (val :Number) :void
    {
        this.displayObject.y = val;
    }

    public function get width () :Number
    {
        return this.displayObject.width;
    }

    public function set width (val :Number) :void
    {
        this.displayObject.width = val;
    }

    public function get height () :Number
    {
        return this.displayObject.height;
    }

    public function set height (val :Number) :void
    {
        this.displayObject.height = val;
    }

    public function get scaleX () :Number
    {
        return this.displayObject.scaleX;
    }

    public function set scaleX (val :Number) :void
    {
        this.displayObject.scaleX = val;
    }

    public function get scaleY () :Number
    {
        return this.displayObject.scaleY;
    }

    public function set scaleY (val :Number) :void
    {
        this.displayObject.scaleY = val;
    }

    public function get visible () :Boolean
    {
        return this.displayObject.visible;
    }

    public function set visible (val :Boolean) :void
    {
        this.displayObject.visible = val;
    }

    public function get rotation () :Number
    {
        return this.displayObject.rotation;
    }

    public function set rotation (val :Number) :void
    {
        this.displayObject.rotation = val;
    }
}

}
