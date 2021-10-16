#!/usr/bin/env python3

# To run this code:
#
# 1. install langcodes: pip install --user langcodes 'langcodes[data]'
#
# 2. run this script from main directory with Valhalla source dir as argument,
#  i.e. tools/generate-valhalla-lang.py ../osmscout/valhalla/valhalla

import string
import langcodes
import os, glob
import sys
import polib

VDIR=sys.argv[1]

###########################
def check_translations(lcode, name):
    for pofile in glob.glob("po/*.po"):
        tgt = pofile.split('/')[1].split('.')[0]
        po = polib.pofile(pofile)
        for entry in po.untranslated_entries():
            if entry.msgid == name:
                entry.msgstr = lcode.display_name(tgt)
                print(entry.msgid, entry.msgstr)
        po.save(pofile)

# get list of all libpostal supported languages
Langs = []
for lng in os.listdir(os.path.join(VDIR, "locales")):
    if lng.find(".json") > 0:
        Langs.append(lng.split(".")[0])

#Langs = ["en_GB", "en_US", "fr_CA", "fr_FR", "de_DE", "ru_RU", "es_MX", "es_ES"]
Langs.sort()

ltxt = '[\n'
for lng in Langs:
    if lng == 'en-US-x-pirate':
        ui = 'app.tr("English Pirate")'
    else:
        lcode = langcodes.get(lng)
        autonym = lcode.autonym()
        name = lcode.display_name()
        #ui = '"%1 / {auto}".arg(app.tr("{name}"))'.format(name=name, auto=autonym)
        ui = 'app.tr("{name}")'.format(name=name, auto=autonym)

        # fill all translations
        check_translations(lcode, name)

    if autonym == lng:
        print("Skipping since we don't know much about it: " + lng)
        continue

    ltxt += '  { "key": "%s", "name": %s },\n' % (lng, ui)
    print(lng, '/', autonym, '/', name)

ltxt = ltxt[:-2] + "\n]"
    
print()
print(ltxt)
