cdef extern from "Elementary.h":

    cpdef enum Elm_List_Mode:
        ELM_LIST_COMPRESS
        ELM_LIST_SCROLL
        ELM_LIST_LIMIT
        ELM_LIST_EXPAND
    ctypedef enum Elm_List_Mode:
        pass

    cpdef enum Elm_Object_Select_Mode:
        ELM_OBJECT_SELECT_MODE_DEFAULT
        ELM_OBJECT_SELECT_MODE_ALWAYS
        ELM_OBJECT_SELECT_MODE_NONE
        ELM_OBJECT_SELECT_MODE_DISPLAY_ONLY
        ELM_OBJECT_SELECT_MODE_MAX
    ctypedef enum Elm_Object_Select_Mode:
        pass

    cpdef enum Elm_Scroller_Policy:
        ELM_SCROLLER_POLICY_AUTO
        ELM_SCROLLER_POLICY_ON
        ELM_SCROLLER_POLICY_OFF
    ctypedef enum Elm_Scroller_Policy:
        pass

    Evas_Object             *elm_list_add(Evas_Object *parent)
    void                     elm_list_go(Evas_Object *obj)
    void                     elm_list_multi_select_set(Evas_Object *obj, Eina_Bool multi)
    Eina_Bool                elm_list_multi_select_get(const Evas_Object *obj)
    void                     elm_list_mode_set(Evas_Object *obj, Elm_List_Mode mode)
    Elm_List_Mode            elm_list_mode_get(const Evas_Object *obj)
    void                     elm_list_horizontal_set(Evas_Object *obj, Eina_Bool horizontal)
    Eina_Bool                elm_list_horizontal_get(const Evas_Object *obj)
    void                     elm_list_select_mode_set(Evas_Object *obj, Elm_Object_Select_Mode mode)
    Elm_Object_Select_Mode   elm_list_select_mode_get(const Evas_Object *obj)
    Elm_Object_Item         *elm_list_item_append(Evas_Object *obj, const char *label, Evas_Object *icon, Evas_Object *end, Evas_Smart_Cb func, void *data)
    Elm_Object_Item         *elm_list_item_prepend(Evas_Object *obj, const char *label, Evas_Object *icon, Evas_Object *end, Evas_Smart_Cb func, void *data)
    Elm_Object_Item         *elm_list_item_insert_before(Evas_Object *obj, Elm_Object_Item *before, const char *label, Evas_Object *icon, Evas_Object *end, Evas_Smart_Cb func, void *data)
    Elm_Object_Item         *elm_list_item_insert_after(Evas_Object *obj, Elm_Object_Item *after, const char *label, Evas_Object *icon, Evas_Object *end, Evas_Smart_Cb func, void *data)
    Elm_Object_Item         *elm_list_item_sorted_insert(Evas_Object *obj, const char *label, Evas_Object *icon, Evas_Object *end, Evas_Smart_Cb func, void *data, Eina_Compare_Cb cmp_func)
    void                     elm_list_clear(Evas_Object *obj)
    Eina_List               *elm_list_items_get(const Evas_Object *obj)
    Elm_Object_Item         *elm_list_selected_item_get(const Evas_Object *obj)
    Eina_List               *elm_list_selected_items_get(const Evas_Object *obj)
    void                     elm_list_item_selected_set(Elm_Object_Item *item, Eina_Bool selected)
    Eina_Bool                elm_list_item_selected_get(const Elm_Object_Item *item)
    void                     elm_list_item_separator_set(Elm_Object_Item *it, Eina_Bool setting)
    Eina_Bool                elm_list_item_separator_get(const Elm_Object_Item *it)
    void                     elm_list_item_show(Elm_Object_Item *item)
    void                     elm_list_item_bring_in(Elm_Object_Item *it)
    Evas_Object             *elm_list_item_object_get(const Elm_Object_Item *item)
    Elm_Object_Item         *elm_list_item_prev(Elm_Object_Item *it)
    Elm_Object_Item         *elm_list_item_next(Elm_Object_Item *it)
    Elm_Object_Item         *elm_list_first_item_get(const Evas_Object *obj)
    Elm_Object_Item         *elm_list_last_item_get(const Evas_Object *obj)

    Elm_Object_Item         *elm_list_at_xy_item_get(const Evas_Object *obj, Evas_Coord x, Evas_Coord y, int *posret)
    void                     elm_list_focus_on_selection_set(Evas_Object *obj, Eina_Bool enabled)
    Eina_Bool                elm_list_focus_on_selection_get(const Evas_Object *obj)