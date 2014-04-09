from efl.evas cimport Eina_Bool, Eina_Compare_Cb, Evas_Object, Evas_Smart_Cb
from object cimport Object
from object_item cimport Elm_Object_Item, ObjectItem

cdef extern from "Elementary.h":
    Evas_Object             *elm_index_add(Evas_Object *parent)
    void                     elm_index_autohide_disabled_set(Evas_Object *obj, Eina_Bool disabled)
    Eina_Bool                elm_index_autohide_disabled_get(const Evas_Object *obj)
    void                     elm_index_item_level_set(Evas_Object *obj, int level)
    int                      elm_index_item_level_get(const Evas_Object *obj)
    void                     elm_index_item_selected_set(Elm_Object_Item *it, Eina_Bool selected)
    Elm_Object_Item         *elm_index_selected_item_get(const Evas_Object *obj, int level)
    Elm_Object_Item         *elm_index_item_append(Evas_Object *obj, const char *letter, Evas_Smart_Cb func, const void *data)
    Elm_Object_Item         *elm_index_item_prepend(Evas_Object *obj, const char *letter, Evas_Smart_Cb func, const void *data)
    Elm_Object_Item         *elm_index_item_insert_after(Evas_Object *obj, Elm_Object_Item *after, const char *letter, Evas_Smart_Cb func, const void *data)
    Elm_Object_Item         *elm_index_item_insert_before(Evas_Object *obj, Elm_Object_Item *before, const char *letter, Evas_Smart_Cb func, const void *data)
    Elm_Object_Item         *elm_index_item_sorted_insert(Evas_Object *obj, const char *letter, Evas_Smart_Cb func, const void *data, Eina_Compare_Cb cmp_func, Eina_Compare_Cb cmp_data_func)
    Elm_Object_Item         *elm_index_item_find(Evas_Object *obj, void *data)
    void                     elm_index_item_clear(Evas_Object *obj)
    void                     elm_index_level_go(Evas_Object *obj, int level)
    char                    *elm_index_item_letter_get(const Elm_Object_Item *item)
    void                     elm_index_indicator_disabled_set(Evas_Object *obj, Eina_Bool disabled)
    Eina_Bool                elm_index_indicator_disabled_get(const Evas_Object *obj)
    void                     elm_index_horizontal_set(Evas_Object *obj, Eina_Bool horizontal)
    Eina_Bool                elm_index_horizontal_get(const Evas_Object *obj)
    void                     elm_index_delay_change_time_set(Evas_Object *obj, double delay_change_time)
    double                   elm_index_delay_change_time_get(const Evas_Object *obj)
    void                     elm_index_omit_enabled_set(Evas_Object *obj, Eina_Bool enabled)
    Eina_Bool                elm_index_omit_enabled_get(const Evas_Object *obj)
