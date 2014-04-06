# Copyright (C) 2007-2013 various contributors (see AUTHORS)
#
# This file is part of Python-EFL.
#
# Python-EFL is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# Python-EFL is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this Python-EFL.  If not, see <http://www.gnu.org/licenses/>.
#

"""

Widget description
------------------

This is a widget specifically for displaying high-resolution digital
camera photos giving speedy feedback (fast load), low memory footprint
and zooming and panning as well as fitting logic. It is entirely focused
on jpeg images, and takes advantage of properties of the jpeg format (via
evas loader features in the jpeg loader).

Signals that you can add callbacks for are:

- ``clicked`` - This is called when a user has clicked the photo without
  dragging around.
- ``press`` - This is called when a user has pressed down on the photo.
- ``longpressed`` - This is called when a user has pressed down on the
  photo for a long time without dragging around.
- ``clicked,double`` - This is called when a user has double-clicked the
  photo.
- ``load`` - Photo load begins.
- ``loaded`` - This is called when the image file load is complete for
  the first view (low resolution blurry version).
- ``load,detail`` - Photo detailed data load begins.
- ``loaded,detail`` - This is called when the image file load is
  complete for the detailed image data (full resolution needed).
- ``zoom,start`` - Zoom animation started.
- ``zoom,stop`` - Zoom animation stopped.
- ``zoom,change`` - Zoom changed when using an auto zoom mode.
- ``scroll`` - the content has been scrolled (moved)
- ``scroll,anim,start`` - scrolling animation has started
- ``scroll,anim,stop`` - scrolling animation has stopped
- ``scroll,drag,start`` - dragging the contents around has started
- ``scroll,drag,stop`` - dragging the contents around has stopped
- ``download,start`` - remote url download has started
- ``download,progress`` - url download in progress
- ``download,end`` - remote url download has finished
- ``download,error`` - remote url download has finished with errors
- ``focused`` - When the photocam has received focus. (since 1.8)
- ``unfocused`` - When the photocam has lost focus. (since 1.8)

Scrollable Interface
====================

This widget supports the scrollable interface.

If you wish to control the scolling behaviour using these functions,
inherit both the widget class and the
:py:class:`~efl.elementary.scroller.Scrollable` class
using multiple inheritance, for example::

    class ScrollableGenlist(Genlist, Scrollable):
        def __init__(self, canvas, *args, **kwargs):
            Genlist.__init__(self, canvas)

Enumerations
------------

.. _Elm_Photocam_Zoom_Mode:

Photocam zoom modes
===================

.. data:: ELM_PHOTOCAM_ZOOM_MODE_MANUAL

    Zoom controlled normally by :py:attr:`~Photocam.zoom`

.. data:: ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT

    Zoom until photo fits in photocam

.. data:: ELM_PHOTOCAM_ZOOM_MODE_AUTO_FILL

    Zoom until photo fills photocam

.. data:: ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT_IN

    Zoom in until photo fits in photocam

"""

from libc.stdint cimport uintptr_t

from efl.eo cimport _object_mapping_register
from efl.utils.conversions cimport _ctouni
from efl.evas cimport Object as evasObject
from object cimport Object

from efl.evas cimport Image as evasImage

from efl.utils.deprecated cimport DEPRECATED
from scroller cimport elm_scroller_policy_get, elm_scroller_policy_set, \
    elm_scroller_bounce_get, elm_scroller_bounce_set, Elm_Scroller_Policy

cimport enums

ELM_PHOTOCAM_ZOOM_MODE_MANUAL = enums.ELM_PHOTOCAM_ZOOM_MODE_MANUAL
ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT = enums.ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT
ELM_PHOTOCAM_ZOOM_MODE_AUTO_FILL = enums.ELM_PHOTOCAM_ZOOM_MODE_AUTO_FILL
ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT_IN = enums.ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT_IN
ELM_PHOTOCAM_ZOOM_MODE_LAST = enums.ELM_PHOTOCAM_ZOOM_MODE_LAST


class PhotocamProgressInfo(object):
    """

    The info sent in the callback for the "download,progress" signals emitted
    by Photocam while downloading remote urls.

    :var now: The amount of data received so far.
    :var total: The total amount of data to download.

    .. versionadded:: 1.8

    """
    def __init__(self):
        self.now = 0
        self.total = 0

def _photocam_download_progress_conv(uintptr_t addr):
    cdef Elm_Photocam_Progress *pp = <Elm_Photocam_Progress *>addr
    ppi = PhotocamProgressInfo()
    ppi.now = pp.now
    ppi.total = pp.total
    return ppi

class PhotocamErrorInfo(object):
    """

    The info sent in the callback for the "download,error" signals emitted
    by Photocam when fail to download remote urls.

    :var status: The http error code (such as 401)
    :var open_error: TODO

    .. versionadded:: 1.8

    """
    def __init__(self):
        self.status = 0
        self.open_error = False

def _photocam_download_error_conv(uintptr_t addr):
    cdef Elm_Photocam_Error *pe = <Elm_Photocam_Error *>addr
    pei = PhotocamErrorInfo()
    pei.status = pe.status
    pei.open_error = pe.open_error
    return pei


cdef class Photocam(Object):

    """This is the class that actually implements the widget."""

    def __init__(self, evasObject parent, *args, **kwargs):
        self._set_obj(elm_photocam_add(parent.obj))
        self._set_properties_from_keyword_args(kwargs)

    property file:
        """The photo file to be shown

        This sets (and shows) the specified file (with a relative or absolute
        path) and will return a load error (same error that
        evas_object_image_load_error_get() will return). The image will
        change and adjust its size at this point and begin a background load
        process for this photo that at some time in the future will be
        displayed at the full quality needed.

        :type: string
        :raise RuntimeError: when setting the file fails

        """
        def __set__(self, filename):
            # TODO: Return EvasLoadError
            if elm_photocam_file_set(self.obj,
                <const char *>filename if filename is not None else NULL) != 0:
                    raise RuntimeError("Could not set file")

        def __get__(self):
            return _ctouni(elm_photocam_file_get(self.obj))

    def file_set(self, filename):
        # TODO: Return EvasLoadError
        if elm_photocam_file_set(self.obj,
            <const char *>filename if filename is not None else NULL) != 0:
                raise RuntimeError("Could not set file")
    def file_get(self):
        return _ctouni(elm_photocam_file_get(self.obj))

    property zoom:
        """The zoom level of the photo

        This sets the zoom level. 1 will be 1:1 pixel for pixel. 2 will be
        2:1 (that is 2x2 photo pixels will display as 1 on-screen pixel).
        4:1 will be 4x4 photo pixels as 1 screen pixel, and so on. The
        parameter must be greater than 0. It is suggested to stick to powers
        of 2. (1, 2, 4, 8, 16, 32, etc.).

        :type: float

        """
        def __set__(self, zoom):
            elm_photocam_zoom_set(self.obj, zoom)
        def __get__(self):
            return elm_photocam_zoom_get(self.obj)

    def zoom_set(self, zoom):
        elm_photocam_zoom_set(self.obj, zoom)
    def zoom_get(self):
        return elm_photocam_zoom_get(self.obj)

    property zoom_mode:
        """Set the zoom mode

        This sets the zoom mode to manual or one of several automatic levels.
        Manual (ELM_PHOTOCAM_ZOOM_MODE_MANUAL) means that zoom is set
        manually by :py:attr:`zoom` and will stay at that level until
        changed by code or until zoom mode is changed. This is the default
        mode. The Automatic modes will allow the photocam object to
        automatically adjust zoom mode based on properties.
        ELM_PHOTOCAM_ZOOM_MODE_AUTO_FIT will adjust zoom so the photo fits
        EXACTLY inside the scroll frame with no pixels outside this region.
        ELM_PHOTOCAM_ZOOM_MODE_AUTO_FILL will be similar but ensure no
        pixels within the frame are left unfilled.

        :type: :ref:`Elm_Photocam_Zoom_Mode`

        """
        def __set__(self, mode):
            elm_photocam_zoom_mode_set(self.obj, mode)
        def __get__(self):
            return elm_photocam_zoom_mode_get(self.obj)

    def zoom_mode_set(self, mode):
        elm_photocam_zoom_mode_set(self.obj, mode)
    def zoom_mode_get(self):
        return elm_photocam_zoom_mode_get(self.obj)

    property image_size:
        """Get the current image pixel width and height

        This gets the current photo pixel width and height (for the
        original). The size will be returned in the integers ``w`` and ``h``
        that are pointed to.

        :type: tuple of ints

        """
        def __get__(self):
            cdef int w, h
            elm_photocam_image_size_get(self.obj, &w, &h)
            return (w, h)

    def image_size_get(self):
        cdef int w, h
        elm_photocam_image_size_get(self.obj, &w, &h)
        return (w, h)

    property image_region:
        """Get the region of the image that is currently shown

        .. seealso:: :py:func:`image_region_show()`
        .. seealso:: :py:func:`image_region_bring_in()`

        :type: tuple of ints

        """
        def __get__(self):
            cdef int x, y, w, h
            elm_photocam_image_region_get(self.obj, &x, &y, &w, &h)
            return (x, y, w, h)

    def image_region_get(self):
        cdef int x, y, w, h
        elm_photocam_image_region_get(self.obj, &x, &y, &w, &h)
        return (x, y, w, h)

    def image_region_show(self, int x, int y, int w, int h):
        """Set the viewed region of the image

        This shows the region of the image without using animation.

        :param x: X-coordinate of region in image original pixels
        :type x: int
        :param y: Y-coordinate of region in image original pixels
        :type y: int
        :param w: Width of region in image original pixels
        :type w: int
        :param h: Height of region in image original pixels
        :type h: int

        """
        elm_photocam_image_region_show(self.obj, x, y, w, h)

    def image_region_bring_in(self, int x, int y, int w, int h):
        """Bring in the viewed portion of the image

        This shows the region of the image using animation.

        :param x: X-coordinate of region in image original pixels
        :type x: int
        :param y: Y-coordinate of region in image original pixels
        :type y: int
        :param w: Width of region in image original pixels
        :type w: int
        :param h: Height of region in image original pixels
        :type h: int

        """
        elm_photocam_image_region_bring_in(self.obj, x, y, w, h)

    property paused:
        """Set the paused state for photocam

        This sets the paused state to on (True) or off (False) for photocam.
        The default is off. This will stop zooming using animation on zoom
        level changes and change instantly. This will stop any existing
        animations that are running.

        :type: bool

        """
        def __set__(self, paused):
            elm_photocam_paused_set(self.obj, paused)
        def __get__(self):
            return bool(elm_photocam_paused_get(self.obj))

    def paused_set(self, paused):
        elm_photocam_paused_set(self.obj, paused)
    def paused_get(self):
        return bool(elm_photocam_paused_get(self.obj))

    property internal_image:
        """Get the internal low-res image used for photocam

        This gets the internal image object inside photocam. Do not modify
        it. It is for inspection only, and hooking callbacks to. Nothing
        else. It may be deleted at any time as well.

        :type: evasImage

        """
        def __get__(self):
            cdef evasImage img = evasImage()
            cdef Evas_Object *obj = elm_photocam_internal_image_get(self.obj)
            img.obj = obj
            return img

    def internal_image_get(self):
        return self.internal_image

    property gesture_enabled:
        """Set the gesture state for photocam.

        This sets the gesture state to on (True) or off (False) for
        photocam. The default is off. This will start multi touch zooming.

        :type: bool

        """
        def __set__(self, gesture):
            elm_photocam_gesture_enabled_set(self.obj, gesture)
        def __get__(self):
            return bool(elm_photocam_gesture_enabled_get(self.obj))

    def gesture_enabled_set(self, gesture):
        elm_photocam_gesture_enabled_set(self.obj, gesture)
    def gesture_enabled_get(self):
        return bool(elm_photocam_gesture_enabled_get(self.obj))

    def callback_clicked_add(self, func, *args, **kwargs):
        """This is called when a user has clicked the photo without dragging
        around."""
        self._callback_add("clicked", func, *args, **kwargs)

    def callback_clicked_del(self, func):
        self._callback_del("clicked", func)

    def callback_press_add(self, func, *args, **kwargs):
        """This is called when a user has pressed down on the photo."""
        self._callback_add("press", func, *args, **kwargs)

    def callback_press_del(self, func):
        self._callback_del("press", func)

    def callback_longpressed_add(self, func, *args, **kwargs):
        """This is called when a user has pressed down on the photo for a
        long time without dragging around."""
        self._callback_add("longpressed", func, *args, **kwargs)

    def callback_longpressed_del(self, func):
        self._callback_del("longpressed", func)

    def callback_clicked_double_add(self, func, *args, **kwargs):
        """This is called when a user has double-clicked the photo."""
        self._callback_add("clicked,double", func, *args, **kwargs)

    def callback_clicked_double_del(self, func):
        self._callback_del("clicked,double", func)

    def callback_load_add(self, func, *args, **kwargs):
        """Photo load begins."""
        self._callback_add("load", func, *args, **kwargs)

    def callback_load_del(self, func):
        self._callback_del("load", func)

    def callback_loaded_add(self, func, *args, **kwargs):
        """This is called when the image file load is complete for the first
        view (low resolution blurry version)."""
        self._callback_add("loaded", func, *args, **kwargs)

    def callback_loaded_del(self, func):
        self._callback_del("loaded", func)

    def callback_load_detail_add(self, func, *args, **kwargs):
        """Photo detailed data load begins."""
        self._callback_add("load,detail", func, *args, **kwargs)

    def callback_load_detail_del(self, func):
        self._callback_del("load,detail", func)

    def callback_loaded_detail_add(self, func, *args, **kwargs):
        """This is called when the image file load is complete for the
        detailed image data (full resolution needed)."""
        self._callback_add("loaded,detail", func, *args, **kwargs)

    def callback_loaded_detail_del(self, func):
        self._callback_del("loaded,detail", func)

    def callback_zoom_start_add(self, func, *args, **kwargs):
        """Zoom animation started."""
        self._callback_add("zoom,start", func, *args, **kwargs)

    def callback_zoom_start_del(self, func):
        self._callback_del("zoom,start", func)

    def callback_zoom_stop_add(self, func, *args, **kwargs):
        """Zoom animation stopped."""
        self._callback_add("zoom,stop", func, *args, **kwargs)

    def callback_zoom_stop_del(self, func):
        self._callback_del("zoom,stop", func)

    def callback_zoom_change_add(self, func, *args, **kwargs):
        """Zoom changed when using an auto zoom mode."""
        self._callback_add("zoom,change", func, *args, **kwargs)

    def callback_zoom_change_del(self, func):
        self._callback_del("zoom,change", func)

    def callback_scroll_add(self, func, *args, **kwargs):
        """The content has been scrolled (moved)."""
        self._callback_add("scroll", func, *args, **kwargs)

    def callback_scroll_del(self, func):
        self._callback_del("scroll", func)

    def callback_scroll_anim_start_add(self, func, *args, **kwargs):
        """Scrolling animation has started."""
        self._callback_add("scroll,anim,start", func, *args, **kwargs)

    def callback_scroll_anim_start_del(self, func):
        self._callback_del("scroll,anim,start", func)

    def callback_scroll_anim_stop_add(self, func, *args, **kwargs):
        """Scrolling animation has stopped."""
        self._callback_add("scroll,anim,stop", func, *args, **kwargs)

    def callback_scroll_anim_stop_del(self, func):
        self._callback_del("scroll,anim,stop", func)

    def callback_scroll_drag_start_add(self, func, *args, **kwargs):
        """Dragging the contents around has started."""
        self._callback_add("scroll,drag,start", func, *args, **kwargs)

    def callback_scroll_drag_start_del(self, func):
        self._callback_del("scroll,drag,start", func)

    def callback_scroll_drag_stop_add(self, func, *args, **kwargs):
        """Dragging the contents around has stopped."""
        self._callback_add("scroll,drag,stop", func, *args, **kwargs)

    def callback_scroll_drag_stop_del(self, func):
        self._callback_del("scroll,drag,stop", func)

    def callback_download_start_add(self, func, *args, **kwargs):
        """This is called when you set a remote url and the download start

        .. versionadded:: 1.8

        """
        self._callback_add("download,start", func, *args, **kwargs)

    def callback_download_start_del(self, func):
        self._callback_del("download,start", func)

    def callback_download_progress_add(self, func, *args, **kwargs):
        """This is called while a remote image download is in progress

        .. versionadded:: 1.8

        """
        self._callback_add_full("download,progress", _photocam_download_progress_conv, func, *args, **kwargs)

    def callback_download_progress_del(self, func):
        self._callback_del_full("download,progress", _photocam_download_progress_conv, func)

    def callback_download_done_add(self, func, *args, **kwargs):
        """This is called when you set a remote url and the download finish

        .. versionadded:: 1.8

        """
        self._callback_add("download,done", func, *args, **kwargs)

    def callback_download_done_del(self, func):
        self._callback_del("download,end", func)

    def callback_download_error_add(self, func, *args, **kwargs):
        """This is called in case a download has errors

        .. versionadded:: 1.8

        """
        self._callback_add_full("download,error", _photocam_download_error_conv, func, *args, **kwargs)

    def callback_download_error_del(self, func):
        self._callback_add_full("download,error", _photocam_download_error_conv, func)

    def callback_focused_add(self, func, *args, **kwargs):
        """When the photocam has received focus.

        .. versionadded:: 1.8
        """
        self._callback_add("focused", func, *args, **kwargs)

    def callback_focused_del(self, func):
        self._callback_del("focused", func)

    def callback_unfocused_add(self, func, *args, **kwargs):
        """When the photocam has lost focus.

        .. versionadded:: 1.8
        """
        self._callback_add("unfocused", func, *args, **kwargs)

    def callback_unfocused_del(self, func):
        self._callback_del("unfocused", func)

    property scroller_policy:
        """

        .. deprecated:: 1.8
            You should combine with Scrollable class instead.

        """
        def __get__(self):
            return self.scroller_policy_get()

        def __set__(self, value):
            cdef Elm_Scroller_Policy policy_h, policy_v
            policy_h, policy_v = value
            self.scroller_policy_set(policy_h, policy_v)

    @DEPRECATED("1.8", "You should combine with Scrollable class instead.")
    def scroller_policy_set(self, policy_h, policy_v):
        elm_scroller_policy_set(self.obj, policy_h, policy_v)
    @DEPRECATED("1.8", "You should combine with Scrollable class instead.")
    def scroller_policy_get(self):
        cdef Elm_Scroller_Policy policy_h, policy_v
        elm_scroller_policy_get(self.obj, &policy_h, &policy_v)
        return (policy_h, policy_v)

    property bounce:
        """

        .. deprecated:: 1.8
            You should combine with Scrollable class instead.

        """
        def __get__(self):
            return self.bounce_get()
        def __set__(self, value):
            cdef Eina_Bool h, v
            h, v = value
            self.bounce_set(h, v)

    @DEPRECATED("1.8", "You should combine with Scrollable class instead.")
    def bounce_set(self, h, v):
        elm_scroller_bounce_set(self.obj, h, v)
    @DEPRECATED("1.8", "You should combine with Scrollable class instead.")
    def bounce_get(self):
        cdef Eina_Bool h, v
        elm_scroller_bounce_get(self.obj, &h, &v)
        return (h, v)

_object_mapping_register("Elm_Photocam", Photocam)
