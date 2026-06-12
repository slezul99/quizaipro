# -*- coding: utf-8 -*-
"""Seed UZ + EN translations for the "История" (History) marketplace decks
added by seed_marketplace_history.py.

Cards in those decks are MCQ, canonical format:
  front = question only
  back  = "X) <correct answer text>"
  note  = "A) ...\\nB) ...\\nC) ...\\nD) ..."

For each card we fill front_uz/back_uz/note_uz and front_en/back_en/note_en
with full translations (same lettered-option format, so both the web parser
(app.py:_parse_card_options) and the mobile parser (api_v1/tests.py
_parse_mcq_options) build a valid localized test/flashcard via
api_v1.tests._localize_card / api_v1.study._serialize_card.

Safe to re-run — skips cards that already have a non-empty front_uz.
"""
import db

conn = db.get_conn()
c = conn.cursor()


def find_card_id(deck_name, front_ru):
    r = c.execute("""
        SELECT c.id, c.front_uz FROM cards c
        JOIN decks d ON d.id = c.deck_id
        WHERE d.name = ? AND c.front = ?
        LIMIT 1
    """, (deck_name, front_ru)).fetchone()
    return r if r else None


def add_translations(deck_name, translations):
    """translations = list of (front_ru, front_uz, back_uz, note_uz,
                                 front_en, back_en, note_en)."""
    updated, skipped, missing = 0, 0, 0
    for front_ru, front_uz, back_uz, note_uz, front_en, back_en, note_en in translations:
        row = find_card_id(deck_name, front_ru)
        if row is None:
            missing += 1
            continue
        cid, existing_uz = row
        if existing_uz:
            skipped += 1
            continue
        c.execute("""UPDATE cards
                      SET front_uz=?, back_uz=?, note_uz=?,
                          front_en=?, back_en=?, note_en=?
                      WHERE id=?""",
                  (front_uz, back_uz, note_uz, front_en, back_en, note_en, cid))
        updated += 1
    print(f"[seed_history_translations] {deck_name}: updated={updated} skipped={skipped} missing={missing}")


print("[seed_history_translations] Starting...")


# ── Древний мир: основы ─────────────────────────────────────────────────────
add_translations("Древний мир: основы", [
    ("Какая цивилизация построила пирамиды в Гизе?",
     "Giza piramidalarini qaysi sivilizatsiya qurgan?",
     "C) Misrliklar",
     "A) Yunonlar\nB) Rimliklar\nC) Misrliklar\nD) Forslar",
     "Which civilization built the pyramids at Giza?",
     "C) Egyptians",
     "A) Greeks\nB) Romans\nC) Egyptians\nD) Persians"),

    ("Кто был первым римским императором?",
     "Birinchi Rim imperatori kim boʻlgan?",
     "B) Avgust (Oktavian)",
     "A) Yuliy Tsezar\nB) Avgust (Oktavian)\nC) Neron\nD) Konstantin",
     "Who was the first Roman emperor?",
     "B) Augustus (Octavian)",
     "A) Julius Caesar\nB) Augustus (Octavian)\nC) Nero\nD) Constantine"),

    ("В каком городе зародилась демократия?",
     "Demokratiya qaysi shaharda paydo boʻlgan?",
     "C) Afina",
     "A) Rim\nB) Sparta\nC) Afina\nD) Bobil",
     "In which city did democracy originate?",
     "C) Athens",
     "A) Rome\nB) Sparta\nC) Athens\nD) Babylon"),

    ("Какая река была основой древнеегипетской цивилизации?",
     "Qadimgi Misr sivilizatsiyasi qaysi daryo asosida rivojlangan?",
     "B) Nil",
     "A) Tigr\nB) Nil\nC) Yevfrat\nD) Hind",
     "Which river was the foundation of ancient Egyptian civilization?",
     "B) Nile",
     "A) Tigris\nB) Nile\nC) Euphrates\nD) Indus"),

    ("Кто создал огромную империю в IV веке до н. э. и не проиграл ни одной битвы?",
     "Miloddan avvalgi IV asrda ulkan imperiya yaratgan va birorta jangda magʻlubiyatga uchramagan sarkarda kim?",
     "A) Aleksandr Makedonskiy",
     "A) Aleksandr Makedonskiy\nB) Hannibal\nC) Tsezar\nD) Kir",
     "Who built a vast empire in the 4th century BC and never lost a battle?",
     "A) Alexander the Great",
     "A) Alexander the Great\nB) Hannibal\nC) Caesar\nD) Cyrus"),

    ("Как называли царей Древнего Египта?",
     "Qadimgi Misr shohlari qanday nomlangan?",
     "B) Faravonlar",
     "A) Shohlar\nB) Faravonlar\nC) Tsezarlar\nD) Sultonlar",
     "What were the kings of Ancient Egypt called?",
     "B) Pharaohs",
     "A) Shahs\nB) Pharaohs\nC) Caesars\nD) Sultans"),

    ("Какая цивилизация изобрела клинопись?",
     "Mixxat yozuvini qaysi sivilizatsiya ixtiro qilgan?",
     "B) Shumer (Mesopotamiya)",
     "A) Misr\nB) Shumer (Mesopotamiya)\nC) Xitoy\nD) Yunoniston",
     "Which civilization invented cuneiform writing?",
     "B) Sumer (Mesopotamia)",
     "A) Egypt\nB) Sumer (Mesopotamia)\nC) China\nD) Greece"),

    ("Кто считается автором «Илиады» и «Одиссеи»?",
     "«Iliada» va «Odisseya» asarlarining muallifi kim hisoblanadi?",
     "B) Gomer",
     "A) Sokrat\nB) Gomer\nC) Platon\nD) Aristotel",
     "Who is considered the author of the \"Iliad\" and the \"Odyssey\"?",
     "B) Homer",
     "A) Socrates\nB) Homer\nC) Plato\nD) Aristotle"),

    ("Древнейший свод законов Вавилона назывался?",
     "Bobilning eng qadimgi qonunlar toʻplami nima deb atalgan?",
     "A) Hammurapi qonunlari",
     "A) Hammurapi qonunlari\nB) Oʻn ikki jadval\nC) Saliy haqiqati\nD) Yustinian kodeksi",
     "What was the oldest code of laws of Babylon called?",
     "A) Code of Hammurabi",
     "A) Code of Hammurabi\nB) Twelve Tables\nC) Salic Law\nD) Code of Justinian"),

    ("В каком году пала Западная Римская империя?",
     "Gʻarbiy Rim imperiyasi qaysi yilda qulagan?",
     "B) 476-yil",
     "A) 410-yil\nB) 476-yil\nC) 800-yil\nD) 1453-yil",
     "In which year did the Western Roman Empire fall?",
     "B) 476",
     "A) 410\nB) 476\nC) 800\nD) 1453"),
])


# ── Средние века: основы ────────────────────────────────────────────────────
add_translations("Средние века: основы", [
    ("Как называлась система отношений «сеньор — вассал»?",
     "«Senyor — vassal» munosabatlari tizimi qanday nomlangan?",
     "B) Feodalizm",
     "A) Demokratiya\nB) Feodalizm\nC) Kapitalizm\nD) Respublika",
     "What was the system of \"lord-vassal\" relations called?",
     "B) Feudalism",
     "A) Democracy\nB) Feudalism\nC) Capitalism\nD) Republic"),

    ("Как называли военно-религиозные походы на Восток в XI–XIII веках?",
     "XI–XIII asrlarda Sharqqa qarshi harbiy-diniy yurishlar qanday nomlangan?",
     "B) Salib yurishlari",
     "A) Rekonkista\nB) Salib yurishlari\nC) Mustamlakachilik\nD) Xalqlarning koʻchishi",
     "What were the military-religious expeditions to the East in the 11th-13th centuries called?",
     "B) Crusades",
     "A) Reconquista\nB) Crusades\nC) Colonization\nD) Migration of peoples"),

    ("Столица Византийской империи?",
     "Vizantiya imperiyasining poytaxti?",
     "C) Konstantinopol",
     "A) Rim\nB) Afina\nC) Konstantinopol\nD) Iskandariya",
     "What was the capital of the Byzantine Empire?",
     "C) Constantinople",
     "A) Rome\nB) Athens\nC) Constantinople\nD) Alexandria"),

    ("В каком году турки взяли Константинополь, завершив историю Византии?",
     "Turklar Konstantinopolni qaysi yilda egallab, Vizantiya tarixiga yakun yasagan?",
     "C) 1453-yil",
     "A) 1054-yil\nB) 1204-yil\nC) 1453-yil\nD) 1492-yil",
     "In which year did the Turks capture Constantinople, ending the history of Byzantium?",
     "C) 1453",
     "A) 1054\nB) 1204\nC) 1453\nD) 1492"),

    ("Кто основал Монгольскую империю?",
     "Mongol imperiyasiga kim asos solgan?",
     "B) Chingizxon",
     "A) Amir Temur\nB) Chingizxon\nC) Botu\nD) Xubilay",
     "Who founded the Mongol Empire?",
     "B) Genghis Khan",
     "A) Tamerlane\nB) Genghis Khan\nC) Batu Khan\nD) Kublai Khan"),

    ("Какая пандемия опустошила Европу в XIV веке?",
     "XIV asrda Yevropani vayron qilgan pandemiya qaysi edi?",
     "B) Qora oʻlat (vaboi taun)",
     "A) Vabo (xolera)\nB) Qora oʻlat (vaboi taun)\nC) Choʻtir\nD) Gripp",
     "Which pandemic devastated Europe in the 14th century?",
     "B) Black Death (plague)",
     "A) Cholera\nB) Black Death (plague)\nC) Smallpox\nD) Influenza"),

    ("Документ 1215 года, ограничивший власть короля Англии?",
     "1215-yilda Angliya qiroli hokimiyatini cheklagan hujjat?",
     "A) Buyuk erkinliklar xartiyasi",
     "A) Buyuk erkinliklar xartiyasi\nB) Mustaqillik deklaratsiyasi\nC) Oltin bulla\nD) Nant edikti",
     "What document of 1215 limited the power of the King of England?",
     "A) Magna Carta",
     "A) Magna Carta\nB) Declaration of Independence\nC) Golden Bull\nD) Edict of Nantes"),

    ("Кто возглавил французов в Столетней войне и стал национальной героиней?",
     "Yuz yillik urushda fransuzlarga boshchilik qilgan va milliy qahramonga aylangan ayol kim?",
     "B) Janna d'Ark",
     "A) Mariya Styuart\nB) Janna d'Ark\nC) Yelizaveta I\nD) Yekaterina Medichi",
     "Who led the French in the Hundred Years' War and became a national heroine?",
     "B) Joan of Arc",
     "A) Mary Stuart\nB) Joan of Arc\nC) Elizabeth I\nD) Catherine de' Medici"),

    ("В каком году произошёл раскол христианства на католичество и православие?",
     "Xristianlikning katoliklik va pravoslavlikka boʻlinishi qaysi yilda yuz bergan?",
     "A) 1054-yil",
     "A) 1054-yil\nB) 1204-yil\nC) 1517-yil\nD) 800-yil",
     "In which year did the split of Christianity into Catholicism and Orthodoxy occur?",
     "A) 1054",
     "A) 1054\nB) 1204\nC) 1517\nD) 800"),

    ("Великий полководец и завоеватель, основавший империю со столицей в Самарканде?",
     "Poytaxti Samarqandda boʻlgan imperiyaga asos solgan buyuk sarkarda va sohibqiron kim?",
     "B) Amir Temur",
     "A) Chingizxon\nB) Amir Temur\nC) Botu\nD) Attila",
     "Which great conqueror founded an empire with its capital in Samarkand?",
     "B) Tamerlane (Amir Temur)",
     "A) Genghis Khan\nB) Tamerlane (Amir Temur)\nC) Batu Khan\nD) Attila"),
])


# ── Новое время: основы ──────────────────────────────────────────────────────
add_translations("Новое время: основы", [
    ("Кто в 1492 году достиг берегов Америки?",
     "1492-yilda Amerika qirgʻoqlariga kim yetib bordi?",
     "B) Xristofor Kolumb",
     "A) Magellan\nB) Xristofor Kolumb\nC) Vasko da Gama\nD) Jeyms Kuk",
     "Who reached the shores of America in 1492?",
     "B) Christopher Columbus",
     "A) Magellan\nB) Christopher Columbus\nC) Vasco da Gama\nD) James Cook"),

    ("Движение за реформу церкви в XVI веке, начатое Мартином Лютером?",
     "XVI asrda Martin Lyuter boshlagan cherkov islohoti harakati?",
     "B) Reformatsiya",
     "A) Uygʻonish davri\nB) Reformatsiya\nC) Maʼrifatchilik\nD) Kontrreformatsiya",
     "What was the 16th-century church reform movement started by Martin Luther called?",
     "B) Reformation",
     "A) Renaissance\nB) Reformation\nC) Enlightenment\nD) Counter-Reformation"),

    ("Кто возглавил первое кругосветное плавание?",
     "Birinchi dunyo boʻylab suzishga kim boshchilik qilgan?",
     "B) Fernand Magellan",
     "A) Kolumb\nB) Fernand Magellan\nC) Dreyk\nD) Kuk",
     "Who led the first voyage around the world?",
     "B) Ferdinand Magellan",
     "A) Columbus\nB) Ferdinand Magellan\nC) Drake\nD) Cook"),

    ("В каком году началась Великая французская революция?",
     "Buyuk Fransiya inqilobi qaysi yilda boshlangan?",
     "A) 1789-yil",
     "A) 1789-yil\nB) 1776-yil\nC) 1804-yil\nD) 1815-yil",
     "In which year did the French Revolution begin?",
     "A) 1789",
     "A) 1789\nB) 1776\nC) 1804\nD) 1815"),

    ("Кто стал императором Франции в 1804 году?",
     "1804-yilda Fransiya imperatori kim boʻldi?",
     "B) Napoleon Bonapart",
     "A) Lyudovik XVI\nB) Napoleon Bonapart\nC) Robesper\nD) Karl X",
     "Who became Emperor of France in 1804?",
     "B) Napoleon Bonaparte",
     "A) Louis XVI\nB) Napoleon Bonaparte\nC) Robespierre\nD) Charles X"),

    ("В какой стране началась промышленная революция?",
     "Sanoat inqilobi qaysi davlatda boshlangan?",
     "C) Buyuk Britaniya",
     "A) Fransiya\nB) Germaniya\nC) Buyuk Britaniya\nD) AQSH",
     "In which country did the Industrial Revolution begin?",
     "C) Great Britain",
     "A) France\nB) Germany\nC) Great Britain\nD) USA"),

    ("В каком году была принята Декларация независимости США?",
     "AQSH Mustaqillik deklaratsiyasi qaysi yilda qabul qilingan?",
     "A) 1776-yil",
     "A) 1776-yil\nB) 1789-yil\nC) 1804-yil\nD) 1812-yil",
     "In which year was the United States Declaration of Independence adopted?",
     "A) 1776",
     "A) 1776\nB) 1789\nC) 1804\nD) 1812"),

    ("Кто сформулировал теорию эволюции путём естественного отбора?",
     "Tabiiy tanlanish orqali evolyutsiya nazariyasini kim ishlab chiqqan?",
     "B) Charlz Darvin",
     "A) Nyuton\nB) Charlz Darvin\nC) Mendel\nD) Paster",
     "Who formulated the theory of evolution by natural selection?",
     "B) Charles Darwin",
     "A) Newton\nB) Charles Darwin\nC) Mendel\nD) Pasteur"),

    ("Эпоха культурного расцвета в Европе XIV–XVI веков?",
     "XIV–XVI asrlarda Yevropada madaniy yuksalish davri qanday nomlangan?",
     "B) Uygʻonish davri (Renessans)",
     "A) Reformatsiya\nB) Uygʻonish davri (Renessans)\nC) Barokko\nD) Maʼrifatchilik",
     "What was the era of cultural flourishing in Europe in the 14th-16th centuries called?",
     "B) Renaissance",
     "A) Reformation\nB) Renaissance\nC) Baroque\nD) Enlightenment"),

    ("В каком году отменили крепостное право в России?",
     "Rossiyada krepostnoylik huquqi qaysi yilda bekor qilingan?",
     "B) 1861-yil",
     "A) 1825-yil\nB) 1861-yil\nC) 1905-yil\nD) 1917-yil",
     "In which year was serfdom abolished in Russia?",
     "B) 1861",
     "A) 1825\nB) 1861\nC) 1905\nD) 1917"),
])


# ── XX век: ключевые даты ─────────────────────────────────────────────────────
add_translations("XX век: ключевые даты", [
    ("В каком году началась Первая мировая война?",
     "Birinchi jahon urushi qaysi yilda boshlangan?",
     "B) 1914-yil",
     "A) 1905-yil\nB) 1914-yil\nC) 1918-yil\nD) 1939-yil",
     "In which year did World War I begin?",
     "B) 1914",
     "A) 1905\nB) 1914\nC) 1918\nD) 1939"),

    ("Революция 1917 года в России привела к власти?",
     "1917-yilgi Rossiya inqilobi hokimiyat tepasiga kimni keltirdi?",
     "B) Bolsheviklarni",
     "A) Monarxistlarni\nB) Bolsheviklarni\nC) Liberallarni\nD) Eserlarni",
     "The 1917 revolution in Russia brought to power:",
     "B) The Bolsheviks",
     "A) The monarchists\nB) The Bolsheviks\nC) The liberals\nD) The Socialist Revolutionaries"),

    ("В каком году началась Вторая мировая война?",
     "Ikkinchi jahon urushi qaysi yilda boshlangan?",
     "B) 1939-yil",
     "A) 1936-yil\nB) 1939-yil\nC) 1941-yil\nD) 1945-yil",
     "In which year did World War II begin?",
     "B) 1939",
     "A) 1936\nB) 1939\nC) 1941\nD) 1945"),

    ("В каком году завершилась Вторая мировая война?",
     "Ikkinchi jahon urushi qaysi yilda tugagan?",
     "C) 1945-yil",
     "A) 1943-yil\nB) 1944-yil\nC) 1945-yil\nD) 1946-yil",
     "In which year did World War II end?",
     "C) 1945",
     "A) 1943\nB) 1944\nC) 1945\nD) 1946"),

    ("Как называлось противостояние СССР и США после 1945 года?",
     "1945-yildan keyingi SSSR va AQSH oʻrtasidagi qarama-qarshilik qanday nomlangan?",
     "B) Sovuq urush",
     "A) Issiq urush\nB) Sovuq urush\nC) Jahon urushi\nD) Fuqarolar urushi",
     "What was the confrontation between the USSR and the USA after 1945 called?",
     "B) Cold War",
     "A) Hot War\nB) Cold War\nC) World War\nD) Civil War"),

    ("Кто первым полетел в космос?",
     "Kosmosga birinchi boʻlib kim uchgan?",
     "B) Yuriy Gagarin",
     "A) Armstrong\nB) Yuriy Gagarin\nC) Korolyov\nD) Tereshkova",
     "Who was the first person to fly into space?",
     "B) Yuri Gagarin",
     "A) Armstrong\nB) Yuri Gagarin\nC) Korolev\nD) Tereshkova"),

    ("В каком году человек впервые высадился на Луну?",
     "Inson Oyga birinchi marta qaysi yilda qadam bosgan?",
     "C) 1969-yil",
     "A) 1957-yil\nB) 1961-yil\nC) 1969-yil\nD) 1975-yil",
     "In which year did humans first land on the Moon?",
     "C) 1969",
     "A) 1957\nB) 1961\nC) 1969\nD) 1975"),

    ("В каком году распался СССР?",
     "SSSR qaysi yilda parchalanib ketdi?",
     "C) 1991-yil",
     "A) 1985-yil\nB) 1989-yil\nC) 1991-yil\nD) 1993-yil",
     "In which year did the USSR collapse?",
     "C) 1991",
     "A) 1985\nB) 1989\nC) 1991\nD) 1993"),

    ("В каком году пала Берлинская стена?",
     "Berlin devori qaysi yilda qulagan?",
     "B) 1989-yil",
     "A) 1985-yil\nB) 1989-yil\nC) 1991-yil\nD) 1993-yil",
     "In which year did the Berlin Wall fall?",
     "B) 1989",
     "A) 1985\nB) 1989\nC) 1991\nD) 1993"),

    ("Какая международная организация была создана в 1945 году для сохранения мира?",
     "1945-yilda tinchlikni saqlash uchun qaysi xalqaro tashkilot tuzilgan?",
     "B) BMT",
     "A) NATO\nB) BMT\nC) YEI\nD) Millatlar Ligasi",
     "Which international organization was founded in 1945 to maintain peace?",
     "B) UN",
     "A) NATO\nB) UN\nC) EU\nD) League of Nations"),
])


conn.commit()
conn.close()
print("[seed_history_translations] Done — UZ + EN translations for 40 History cards")
