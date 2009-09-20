package com.threerings.ui.snapping {
import flash.geom.Rectangle;

public interface ISnapAnchor
{
    //function get globalBounds () :Rectangle;

    function getSnappableDistance (d :ISnappingObject) :Number;

//    function isSnappable (snappable :ISnappingObject) :Boolean;

    function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean;

    function snapObject (snappable :ISnappingObject) :void;

//    function get type () :SnapType;

    function get provider () :Object;

    function get index () :int;
    
    


}
}