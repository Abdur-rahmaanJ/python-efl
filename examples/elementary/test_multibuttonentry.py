#!/usr/bin/env python
# encoding: utf-8

from efl import evas
from efl import elementary
from efl.elementary.window import Window
from efl.elementary.background import Background
from efl.elementary.box import Box
from efl.elementary.button import Button
from efl.elementary.entry import Entry
from efl.elementary.multibuttonentry import MultiButtonEntry
from efl.elementary.scroller import Scroller


counter = 0

def cb_item_selected(mbe, *args, **kwargs):
    # XXX: This gets called twice
    print(mbe)

def cb_btn_item_prepend(btn, mbe):
    global counter

    counter += 1
    item = mbe.item_prepend("item #%d" % (counter), cb_item_selected)

def cb_btn_item_append(btn, mbe):
    global counter

    counter += 1
    item = mbe.item_append("item #%d" % (counter), cb_item_selected)

def cb_btn_item_insert_after(btn, mbe):
    global counter

    counter += 1
    after = mbe.selected_item
    item = mbe.item_insert_after(after, "item #%d" % (counter), cb_item_selected)

def cb_btn_item_insert_before(btn, mbe):
    global counter

    counter += 1
    before = mbe.selected_item
    item = mbe.item_insert_before(before, "item #%d" % (counter), cb_item_selected)

def cb_btn_clear2(btn, mbe):
    for item in mbe.items:
        item.delete()

def cb_filter1(mbe, text):
    print(text)
    return True

def cb_print(btn, mbe):
    for i in mbe.items:
        print(i.text)

def multibuttonentry_clicked(obj, item=None):
    win = Window("multibuttonentry", elementary.ELM_WIN_BASIC)
    win.title_set("MultiButtonEntry test")
    win.autodel_set(True)
    if obj is None:
        win.callback_delete_request_add(lambda o: elementary.exit())

    bg = Background(win)
    win.resize_object_add(bg)
    bg.size_hint_weight_set(evas.EVAS_HINT_EXPAND, evas.EVAS_HINT_EXPAND)
    bg.show()

    vbox = Box(win)
    vbox.size_hint_weight = (evas.EVAS_HINT_EXPAND, evas.EVAS_HINT_EXPAND)
    win.resize_object_add(vbox)
    vbox.show()

    sc = Scroller(win)
    sc.bounce = (False, True)
    sc.policy = (elementary.ELM_SCROLLER_POLICY_OFF, elementary.ELM_SCROLLER_POLICY_AUTO)
    sc.size_hint_align = (evas.EVAS_HINT_FILL, evas.EVAS_HINT_FILL)
    sc.size_hint_weight = (evas.EVAS_HINT_EXPAND, evas.EVAS_HINT_EXPAND)
    vbox.pack_end(sc)
    sc.show()

    mbe = MultiButtonEntry(win)
    mbe.callback_item_selected_add(cb_item_selected)
    mbe.size_hint_align = (evas.EVAS_HINT_FILL, evas.EVAS_HINT_FILL)
    mbe.size_hint_weight = (evas.EVAS_HINT_EXPAND, evas.EVAS_HINT_EXPAND)
    mbe.text = "To: "
    mbe.part_text_set("guide", "Tap to add recipient")
    mbe.filter_append(cb_filter1)
    sc.content = mbe
    mbe.show()

    print(mbe.entry)

    hbox = Box(win)
    hbox.horizontal = True
    hbox.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    vbox.pack_end(hbox)
    hbox.show()

    bt = Button(win)
    bt.text = "item_append"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(cb_btn_item_append, mbe)
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "item_prepend"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(cb_btn_item_prepend, mbe)
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "item_insert_after"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(cb_btn_item_insert_after, mbe)
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "item_insert_before"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(cb_btn_item_insert_before, mbe)
    hbox.pack_end(bt)
    bt.show()


    hbox = Box(win)
    hbox.horizontal = True
    hbox.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    vbox.pack_end(hbox)
    hbox.show()

    bt = Button(win)
    bt.text = "delete selected item"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(lambda btn: mbe.selected_item.delete())
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "clear"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(lambda bt: mbe.clear())
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "clear2"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(cb_btn_clear2, mbe)
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "toggle expand"
    bt.size_hint_align = (evas.EVAS_HINT_FILL, 0.0)
    bt.size_hint_weight = (evas.EVAS_HINT_EXPAND, 0.0)
    bt.callback_clicked_add(lambda btn: mbe.expanded_set(not mbe.expanded_get()))
    hbox.pack_end(bt)
    bt.show()

    bt = Button(win)
    bt.text = "print"
    bt.size_hint_align = evas.EVAS_HINT_FILL, 0.0
    bt.size_hint_weight = evas.EVAS_HINT_EXPAND, 0.0
    bt.callback_clicked_add(cb_print, mbe)
    hbox.pack_end(bt)
    bt.show()

    mbe.focus = True
    win.resize(320, 320)
    win.show()


if __name__ == "__main__":
    elementary.init()

    multibuttonentry_clicked(None)

    elementary.run()
    elementary.shutdown()

