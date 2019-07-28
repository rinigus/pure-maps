import json
from iso639 import languages

langs = """

    mul – Local
    ara – Arabic
    baq – Basque
    cat – Catalan
    chi – Chinese (simplified)
    cht – Chinese (traditional)
    cze – Czech
    dan – Danish
    dut – Dutch
    eng – English
    fin – Finnish
    fre – French
    ger – German
    gle – Gaelic
    gre – Greek
    heb – Hebrew
    hin – Hindi
    ind – Indonesian
    ita – Italian
    nor – Norwegian
    per – Persian
    pol – Polish
    por – Portuguese
    rus – Russian
    sin – Sinhalese
    spa – Spanish
    swe – Swedish
    tha – Thai
    tur – Turkish
    ukr – Ukrainian
    urd – Urdu
    vie – Vietnamese
    wel – Welsh
"""

corrected = { 'chi': 'zh-simpl', 'cht': 'zh', 'mul': 'local' }

jsel = {}
model = "model: ["
vals = "values: ["
for l in langs.split("\n"):
    l = l.split('–')
    if len(l) == 2:
        l3, name = l[0].strip(), l[1].strip()
        if l3 in corrected:
            a2 = corrected[l3]
            cname = 'XXX'
        else:
            c = languages.get(part2b = l3)
            a2 = c.alpha2
            cname = c.name
        print(a2, cname, l3, name)
        jsel[a2] = l3
        model += '\napp.tr("%s"),' % name
        vals += '\n"%s",' % a2

model = model[:-1] + "\n]"
vals = vals[:-1] + "\n]"

print("\n\n")
print(json.dumps(jsel))

print("\n\n")
print(model)

print("\n\n")
print(vals)
