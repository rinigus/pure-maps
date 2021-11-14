#!/usr/bin/env python3

# To run this code:
#
# 1. get router-here-lang.csv by copying list from
# https://developer.here.com/documentation/routing-api/dev_guide/topics/languages.html
# into LibreOffice Calc and saving it into CSV
#
# 2. run this script from main directory python tools/generate-router-here-lang.py

import csv
import glob
import langcodes
import polib
from addict import Dict

def check_translations(lcode, name):
    for pofile in glob.glob("po/*.po"):
        tgt = pofile.split('/')[1].split('.')[0]
        po = polib.pofile(pofile)
        for entry in po.untranslated_entries():
            if entry.msgid == name:
                entry.msgstr = lcode.display_name(tgt)
                print(entry.msgid, entry.msgstr)
        po.save(pofile)

# get list of all supported languages
Langs = []
with open('tools/router-here-lang.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        d = Dict(
            lang=row['language'].strip(),
            code=row['code'].split(',')[-1].strip()
            )
        Langs.append(d)

# for l in Langs:
#     lcode = langcodes.get(l.code)
#     print(l.code, lcode.display_name(), lcode.autonym())

# #Langs = ["en_GB", "en_US", "fr_CA", "fr_FR", "de_DE", "ru_RU", "es_MX", "es_ES"]
#Langs.sort()

ltxt = '[\n'
for L in Langs:
    lng = L.code
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
    print(lng, '/', autonym, '/', name, '/', L.lang)

ltxt = ltxt[:-2] + "\n]"
    
print()
print(ltxt)
