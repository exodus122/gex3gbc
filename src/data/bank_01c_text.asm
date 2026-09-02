; ==================================================================
; BANK $1C - ALL OF THE GAME'S TEXT
;
; Every string the menu system draws lives here, in FIVE LANGUAGES.
;
; ------------------------------------------------------------------
; How a string is reached
; ------------------------------------------------------------------
; A menu command does not point at a string. It points at a ten-byte table of
; five pointers - English, French, German, Spanish, Italian - and
; call_00_0835_Text_LoadStringToBuffer picks one with
; wDBF8_TextStringIndex before copying it to wDADD_MenuTextBuffer.
;
; NOTHING IN THE ROM EVER WRITES wDBF8_TextStringIndex. It is cleared with the
; rest of WRAM at boot and stays $00, so this build always draws entry 0 and the
; other four languages are dead weight - roughly two thirds of the bank.
;
; The screen that would have set it is still here too. Records
; Text_LanguageEnglish through Text_LanguageItaliano name the five languages,
; each in its own language, and they are exactly the five rows of
; data_01_580a_MenuScript_LanguageSelect - a menu with a backdrop of its own
; (MENU_IMAGE_LANGUAGE_SELECT), a five-option MENU_* record, and no caller.
;
; Where all five languages would use the same string - names, legal notices, the
; password keyboard - the record still has five pointers and they all point at
; the one string. 67 of the 84 menu records are like that.
;
; ------------------------------------------------------------------
; How a string is stored
; ------------------------------------------------------------------
; Plain ASCII, lower case, ending in a byte with bit 7 set. That byte is copied
; into the buffer along with the rest and is normally a lone TEXT_TERMINATOR,
; whose low seven bits are $00 - the blank glyph - so drawing it is harmless.
; There is no length byte and no separate line terminator.
;
; ------------------------------------------------------------------
; Accented characters
; ------------------------------------------------------------------
; The font has no capitals: glyphs $01-$1A are A-Z and lower case ASCII is what
; reaches them. That leaves the UPPER CASE ASCII range free, and the translations
; use it for accented vowels and punctuation. .data_01_4dfd_CharToGlyph does the
; mapping and the glyphs sit in five neat runs of five vowels, one run per
; diacritic:
;
;   A B C D E  ->  $25-$29  a e i o u with a DIAERESIS   ä ë ï ö ü
;   F G H I J  ->  $2A-$2E  ...with an ACUTE             á é í ó ú
;   K L M N O  ->  $2F-$33  ...with a GRAVE              à è ì ò ù
;   P Q R S T  ->  $34-$38  ...with a CIRCUMFLEX         â ê î ô û
;   U          ->  $3B      inverted exclamation mark    ¡
;   V          ->  $3C      sharp s                      ß
;   W          ->  $3D      n with tilde                 ñ
;   X          ->  $45      trade mark sign              (tm)
;   Y          ->  $46      copyright sign               (c)
;
; So "paVwort" is paßwort and "botIn" is boton with an acute. Every string below
; that uses one carries its reading in a comment. Z is the one letter with no
; glyph at all - no accented character needed it.
;
; There is one mistake in the data: the German "bekAmpfen sie den verrJckten
; bomber" spells verrückten with J, the ACUTE u, where every other German string
; uses E for the diaeresis. It renders as verrucken with the wrong mark. Left as
; it is - this file has to assemble back to the original bytes.
;
; ------------------------------------------------------------------
; Layout
; ------------------------------------------------------------------
; Menu and credit records come first, each table immediately followed by its own
; strings. Then Text_CounterStrings, then the twelve per-level blocks, which
; group their five tables together before their strings. The bank ends at $678D
; and the rest is link padding
; ==================================================================
; ------------------------------------------------------------------
; OPENING AND END CREDITS
;
; All single-string records - names and legal notices were not translated.
; The credit SCREENS are data_01_5843_MenuScript_OpeningCredits1 onwards,
; which stack these down a full-screen menu command block
; ------------------------------------------------------------------

Text_TitleGexDeepPocketGecko:
    text_all_langs Text_TitleGexDeepPocketGecko_Str
Text_TitleGexDeepPocketGecko_Str:
    db   "gex - deep pocket gecko", TEXT_TERMINATOR

Text_PublishedByEidos:
    text_all_langs Text_PublishedByEidos_Str
Text_PublishedByEidos_Str:
    db   "published by eidos interactive ltd", TEXT_TERMINATOR

Text_CrystalDynamicsRights:
    text_all_langs Text_CrystalDynamicsRights_Str
Text_CrystalDynamicsRights_Str:   ; (c) crystal dynamics. all rights reserved.
    db   "Y crystal dynamics. all rights reserved.", TEXT_TERMINATOR

Text_NintendoLicenceLine:
    text_all_langs Text_NintendoLicenceLine_Str
Text_NintendoLicenceLine_Str:   ; nintendo(tm) game boy color(tm) version, (c) 1999 david a. palmer productions (usa).
    db   "nintendoX game boy colorX version, Y 1999 david a. palmer productions (usa).", TEXT_TERMINATOR

Text_LicensedByNintendo:
    text_all_langs Text_LicensedByNintendo_Str
Text_LicensedByNintendo_Str:
    db   "licensed by nintendo", TEXT_TERMINATOR

Text_GexTrademarkNotice:
    text_all_langs Text_GexTrademarkNotice_Str
Text_GexTrademarkNotice_Str:   ; gex, the gex character and the related characters are trademarks of crystal dynamics. (c) 1999 crystal dynamics.
    db   "gex, the gex character and the related characters are trademarks of crystal dynamics. Y 1999 crystal dynamics.", TEXT_TERMINATOR

Text_CrystalSubsidiaryNotice:
    text_all_langs Text_CrystalSubsidiaryNotice_Str
Text_CrystalSubsidiaryNotice_Str:
    db   "crystal dynamics is a wholly owned subsidiary of eidos interactive.", TEXT_TERMINATOR

Text_EidosTrademarkNotice:
    text_all_langs Text_EidosTrademarkNotice_Str
Text_EidosTrademarkNotice_Str:
    db   "eidos, eidos interactive and the eidos logo are registered trademarks of eidos interactive, inc.", TEXT_TERMINATOR

Text_EidosCopyright:
    text_all_langs Text_EidosCopyright_Str
Text_EidosCopyright_Str:   ; (c) 1999. eidos interactive, inc. all rights reserved.
    db   "Y 1999. eidos interactive, inc. all rights reserved.", TEXT_TERMINATOR

Text_HeadingCrystalEidos:
    text_all_langs Text_HeadingCrystalEidos_Str
Text_HeadingCrystalEidos_Str:
    db   "crystal dynamics / eidos", TEXT_TERMINATOR

Text_HeadingExecProducer:
    text_all_langs Text_HeadingExecProducer_Str
Text_HeadingExecProducer_Str:
    db   "executive producer", TEXT_TERMINATOR

Text_NameSamPlayer:
    text_all_langs Text_NameSamPlayer_Str
Text_NameSamPlayer_Str:
    db   "sam player", TEXT_TERMINATOR

Text_HeadingTestManager:
    text_all_langs Text_HeadingTestManager_Str
Text_HeadingTestManager_Str:
    db   "test manager", TEXT_TERMINATOR

Text_NameAlexNess:
    text_all_langs Text_NameAlexNess_Str
Text_NameAlexNess_Str:
    db   "alex ness", TEXT_TERMINATOR

Text_HeadingLeadTester:
    text_all_langs Text_HeadingLeadTester_Str
Text_HeadingLeadTester_Str:
    db   "lead tester", TEXT_TERMINATOR

Text_NameRichKrinock:
    text_all_langs Text_NameRichKrinock_Str
Text_NameRichKrinock_Str:
    db   "rich krinock", TEXT_TERMINATOR

Text_HeadingTesters:
    text_all_langs Text_HeadingTesters_Str
Text_HeadingTesters_Str:
    db   "testers", TEXT_TERMINATOR

Text_NameBrianBecksted:
    text_all_langs Text_NameBrianBecksted_Str
Text_NameBrianBecksted_Str:
    db   "brian becksted", TEXT_TERMINATOR

Text_NameChrisBruno:
    text_all_langs Text_NameChrisBruno_Str
Text_NameChrisBruno_Str:
    db   "chris bruno", TEXT_TERMINATOR

Text_NameRolefConlan:
    text_all_langs Text_NameRolefConlan_Str
Text_NameRolefConlan_Str:
    db   "rolef conlan", TEXT_TERMINATOR

Text_NameJoeDamon:
    text_all_langs Text_NameJoeDamon_Str
Text_NameJoeDamon_Str:
    db   "joe damon", TEXT_TERMINATOR

Text_NameRyanEllison:
    text_all_langs Text_NameRyanEllison_Str
Text_NameRyanEllison_Str:
    db   "ryan ellison", TEXT_TERMINATOR

Text_NameMarkMedeiros:
    text_all_langs Text_NameMarkMedeiros_Str
Text_NameMarkMedeiros_Str:
    db   "mark medeiros", TEXT_TERMINATOR

Text_NameBillyMitchell:
    text_all_langs Text_NameBillyMitchell_Str
Text_NameBillyMitchell_Str:
    db   "billy mitchell", TEXT_TERMINATOR

Text_NameJacobRohrer:
    text_all_langs Text_NameJacobRohrer_Str
Text_NameJacobRohrer_Str:
    db   "jacob rohrer", TEXT_TERMINATOR

Text_NameBenWalker:
    text_all_langs Text_NameBenWalker_Str
Text_NameBenWalker_Str:
    db   "ben walker", TEXT_TERMINATOR

Text_HeadingMarketingManager:
    text_all_langs Text_HeadingMarketingManager_Str
Text_HeadingMarketingManager_Str:
    db   "product marketing manager", TEXT_TERMINATOR

Text_NameChipBlundell:
    text_all_langs Text_NameChipBlundell_Str
Text_NameChipBlundell_Str:
    db   "chip blundell", TEXT_TERMINATOR

Text_HeadingSpecialThanks:
    text_all_langs Text_HeadingSpecialThanks_Str
Text_HeadingSpecialThanks_Str:
    db   "special thanks to", TEXT_TERMINATOR

Text_NameAndrewBennett:
    text_all_langs Text_NameAndrewBennett_Str
Text_NameAndrewBennett_Str:
    db   "andrew bennett", TEXT_TERMINATOR

Text_NamePatrickCowan:
    text_all_langs Text_NamePatrickCowan_Str
Text_NamePatrickCowan_Str:
    db   "patrick cowan", TEXT_TERMINATOR

Text_NameRobDyer:
    text_all_langs Text_NameRobDyer_Str
Text_NameRobDyer_Str:
    db   "rob dyer", TEXT_TERMINATOR

Text_NameNickEarl:
    text_all_langs Text_NameNickEarl_Str
Text_NameNickEarl_Str:
    db   "nick earl", TEXT_TERMINATOR

Text_NameBrianKemp:
    text_all_langs Text_NameBrianKemp_Str
Text_NameBrianKemp_Str:
    db   "brian kemp", TEXT_TERMINATOR

Text_NameRoseMontgomery:
    text_all_langs Text_NameRoseMontgomery_Str
Text_NameRoseMontgomery_Str:
    db   "rose montgomery", TEXT_TERMINATOR

Text_NameSimonOrams:
    text_all_langs Text_NameSimonOrams_Str
Text_NameSimonOrams_Str:
    db   "simon orams", TEXT_TERMINATOR

Text_NameReneePletka:
    text_all_langs Text_NameReneePletka_Str
Text_NameReneePletka_Str:
    db   "renee pletka", TEXT_TERMINATOR

Text_NameJamesPoole:
    text_all_langs Text_NameJamesPoole_Str
Text_NameJamesPoole_Str:
    db   "james poole", TEXT_TERMINATOR

Text_NameGregRizzer:
    text_all_langs Text_NameGregRizzer_Str
Text_NameGregRizzer_Str:
    db   "greg rizzer", TEXT_TERMINATOR

Text_NameGlenSchofield:
    text_all_langs Text_NameGlenSchofield_Str
Text_NameGlenSchofield_Str:
    db   "glen schofield", TEXT_TERMINATOR

Text_NameFlaviaTimiani:
    text_all_langs Text_NameFlaviaTimiani_Str
Text_NameFlaviaTimiani_Str:
    db   "flavia timiani", TEXT_TERMINATOR

Text_HeadingProducedByPalmer:
    text_all_langs Text_HeadingProducedByPalmer_Str
Text_HeadingProducedByPalmer_Str:
    db   "produced by david a. palmer productions", TEXT_TERMINATOR

Text_HeadingSheffieldUk:
    text_all_langs Text_HeadingSheffieldUk_Str
Text_HeadingSheffieldUk_Str:
    db   "sheffield. u.k.", TEXT_TERMINATOR

Text_HeadingProjectManager:
    text_all_langs Text_HeadingProjectManager_Str
Text_HeadingProjectManager_Str:
    db   "project manager / producer", TEXT_TERMINATOR

Text_NameDavePalmer:
    text_all_langs Text_NameDavePalmer_Str
Text_NameDavePalmer_Str:
    db   "dave palmer", TEXT_TERMINATOR

Text_HeadingProgramming:
    text_all_langs Text_HeadingProgramming_Str
Text_HeadingProgramming_Str:
    db   "programming", TEXT_TERMINATOR

Text_NameRoo:
    text_all_langs Text_NameRoo_Str
Text_NameRoo_Str:
    db   "roo", TEXT_TERMINATOR

Text_HeadingMusicAndSfx:
    text_all_langs Text_HeadingMusicAndSfx_Str
Text_HeadingMusicAndSfx_Str:
    db   "music and sfx", TEXT_TERMINATOR

Text_NameMarkCooksey:
    text_all_langs Text_NameMarkCooksey_Str
Text_NameMarkCooksey_Str:
    db   "mark cooksey", TEXT_TERMINATOR

Text_HeadingLeadArtist:
    text_all_langs Text_HeadingLeadArtist_Str
Text_HeadingLeadArtist_Str:
    db   "lead artist", TEXT_TERMINATOR

Text_NameIanTerry:
    text_all_langs Text_NameIanTerry_Str
Text_NameIanTerry_Str:
    db   "ian terry", TEXT_TERMINATOR

Text_HeadingSupportArtist:
    text_all_langs Text_HeadingSupportArtist_Str
Text_HeadingSupportArtist_Str:
    db   "support artist", TEXT_TERMINATOR

Text_NameDaveGarrison:
    text_all_langs Text_NameDaveGarrison_Str
Text_NameDaveGarrison_Str:
    db   "dave garrison", TEXT_TERMINATOR

Text_HeadingTesters2:
    text_all_langs Text_HeadingTesters2_Str
Text_HeadingTesters2_Str:
    db   "testers", TEXT_TERMINATOR

Text_NameNeilPalmer:
    text_all_langs Text_NameNeilPalmer_Str
Text_NameNeilPalmer_Str:
    db   "neil palmer", TEXT_TERMINATOR

Text_HeadingSpecialThanks2:
    text_all_langs Text_HeadingSpecialThanks2_Str
Text_HeadingSpecialThanks2_Str:
    db   "special thanks to", TEXT_TERMINATOR

Text_NameDavidMBoyles:
    text_all_langs Text_NameDavidMBoyles_Str
Text_NameDavidMBoyles_Str:
    db   "david m. boyles", TEXT_TERMINATOR

Text_NameGailOxley:
    text_all_langs Text_NameGailOxley_Str
Text_NameGailOxley_Str:
    db   "gail oxley", TEXT_TERMINATOR

Text_NamePeterLeonard:
    text_all_langs Text_NamePeterLeonard_Str
Text_NamePeterLeonard_Str:
    db   "peter leonard", TEXT_TERMINATOR

; ------------------------------------------------------------------
; THE LANGUAGE MENU
;
; The five rows of data_01_580a_MenuScript_LanguageSelect, each naming a
; language in that language. This is the screen that would set the index
; every table in this bank is read with - see the header. Nothing opens it,
; and nothing writes the index either way
; ------------------------------------------------------------------

Text_LanguageEnglish:
    text_all_langs Text_LanguageEnglish_Str
Text_LanguageEnglish_Str:
    db   "english", TEXT_TERMINATOR

Text_LanguageFrancais:
    text_all_langs Text_LanguageFrancais_Str
Text_LanguageFrancais_Str:
    db   "francais", TEXT_TERMINATOR

Text_LanguageDeutsch:
    text_all_langs Text_LanguageDeutsch_Str
Text_LanguageDeutsch_Str:
    db   "deutsch", TEXT_TERMINATOR

Text_LanguageEspanol:
    text_all_langs Text_LanguageEspanol_Str
Text_LanguageEspanol_Str:
    db   "espanol", TEXT_TERMINATOR

Text_LanguageItaliano:
    text_all_langs Text_LanguageItaliano_Str
Text_LanguageItaliano_Str:
    db   "italiano", TEXT_TERMINATOR

; ------------------------------------------------------------------
; MENU STRINGS - the translated ones
; ------------------------------------------------------------------

Text_NewGame:
    text_langs Text_NewGame_En, Text_NewGame_Fr, Text_NewGame_De, Text_NewGame_Es, Text_NewGame_It
Text_NewGame_En:
    db   "new game", TEXT_TERMINATOR
Text_NewGame_Fr:
    db   "nouvelle partie", TEXT_TERMINATOR
Text_NewGame_De:
    db   "neues spiel", TEXT_TERMINATOR
Text_NewGame_Es:
    db   "nueva partida", TEXT_TERMINATOR
Text_NewGame_It:
    db   "nuova partita", TEXT_TERMINATOR

Text_Password:
    text_langs Text_Password_En, Text_Password_Fr, Text_Password_De, Text_Password_Es, Text_Password_It
Text_Password_En:
    db   "password", TEXT_TERMINATOR
Text_Password_Fr:
    db   "mot de passe", TEXT_TERMINATOR
Text_Password_De:   ; paßwort
    db   "paVwort", TEXT_TERMINATOR
Text_Password_Es:   ; contraseña
    db   "contraseWa", TEXT_TERMINATOR
Text_Password_It:
    db   "password", TEXT_TERMINATOR

Text_ChooseAHint:
    text_langs Text_ChooseAHint_En, Text_ChooseAHint_Fr, Text_ChooseAHint_De, Text_ChooseAHint_Es, Text_ChooseAHint_It
Text_ChooseAHint_En:
    db   "choose a hint then press b button to continue", TEXT_TERMINATOR
Text_ChooseAHint_Fr:
    db   "choisissez l'un des objectifs et appuyez sur le bouton b pour continuer", TEXT_TERMINATOR
Text_ChooseAHint_De:   ; wählen sie einen hinweis, drücken sie dann den b-knopf
    db   "wAhlen sie einen hinweis, drEcken sie dann den b-knopf", TEXT_TERMINATOR
Text_ChooseAHint_Es:   ; elige una pista y pulsa el botón b para continuar
    db   "elige una pista y pulsa el botIn b para continuar", TEXT_TERMINATOR
Text_ChooseAHint_It:
    db   "scegli un suggerimento e premi pulsante b", TEXT_TERMINATOR

Text_PressBToContinue:
    text_langs Text_PressBToContinue_En, Text_PressBToContinue_Fr, Text_PressBToContinue_De, Text_PressBToContinue_Es, Text_PressBToContinue_It
Text_PressBToContinue_En:
    db   "press b button to continue", TEXT_TERMINATOR
Text_PressBToContinue_Fr:
    db   "appuyez sur le bouton b pour continuer", TEXT_TERMINATOR
Text_PressBToContinue_De:   ; drücken sie den b-knopf, um fortzufahren
    db   "drEcken sie den b-knopf, um fortzufahren", TEXT_TERMINATOR
Text_PressBToContinue_Es:   ; pulsa el botón b para continuar
    db   "pulsa el botIn b para continuar", TEXT_TERMINATOR
Text_PressBToContinue_It:
    db   "premi pulsante b per continuare", TEXT_TERMINATOR

Text_LeftRightToToggle:
    text_langs Text_LeftRightToToggle_En, Text_LeftRightToToggle_Fr, Text_LeftRightToToggle_De, Text_LeftRightToToggle_Es, Text_LeftRightToToggle_It
Text_LeftRightToToggle_En:
    db   "left/right to toggle", TEXT_TERMINATOR
Text_LeftRightToToggle_Fr:
    db   "gauche/droit pour faire defiler", TEXT_TERMINATOR
Text_LeftRightToToggle_De:   ; links/rechts für an/aus
    db   "links/rechts fEr an/aus", TEXT_TERMINATOR
Text_LeftRightToToggle_Es:
    db   "izquierda/derecha para hacer avanza", TEXT_TERMINATOR
Text_LeftRightToToggle_It:
    db   "sinistra/destra per cambiare", TEXT_TERMINATOR

Text_Slash:
    text_all_langs Text_Slash_Str
Text_Slash_Str:
    db   "/", TEXT_TERMINATOR

Text_Congratulations:
    text_langs Text_Congratulations_En, Text_Congratulations_Fr, Text_Congratulations_De, Text_Congratulations_Es, Text_Congratulations_It
Text_Congratulations_En:
    db   "congratulations!", TEXT_TERMINATOR
Text_Congratulations_Fr:
    db   "felicitations", TEXT_TERMINATOR
Text_Congratulations_De:   ; glückwunsch
    db   "glEckwunsch", TEXT_TERMINATOR
Text_Congratulations_Es:   ; ¡enhorabuena!
    db   "Uenhorabuena!", TEXT_TERMINATOR
Text_Congratulations_It:
    db   "congratulazioni!", TEXT_TERMINATOR

Text_XOf4RemotesFound:
    text_langs Text_XOf4RemotesFound_En, Text_XOf4RemotesFound_Fr, Text_XOf4RemotesFound_De, Text_XOf4RemotesFound_Es, Text_XOf4RemotesFound_It
Text_XOf4RemotesFound_En:
    db   "x of 4 remotes found", TEXT_TERMINATOR
Text_XOf4RemotesFound_Fr:
    db   "x des 4 telecommandes rouges decouvertes", TEXT_TERMINATOR
Text_XOf4RemotesFound_De:
    db   "x von 4 fernbedienungen gefunden", TEXT_TERMINATOR
Text_XOf4RemotesFound_Es:
    db   "x de 4 mandos a distancia rojos encontrados", TEXT_TERMINATOR
Text_XOf4RemotesFound_It:
    db   "x telecomandi rossi su 4 trovati", TEXT_TERMINATOR

Text_TimeUp:
    text_langs Text_TimeUp_En, Text_TimeUp_Fr, Text_TimeUp_De, Text_TimeUp_Es, Text_TimeUp_It
Text_TimeUp_En:
    db   "time up!", TEXT_TERMINATOR
Text_TimeUp_Fr:
    db   "temps ecoule", TEXT_TERMINATOR
Text_TimeUp_De:
    db   "zeit abgelaufen", TEXT_TERMINATOR
Text_TimeUp_Es:
    db   "fin del tiempo", TEXT_TERMINATOR
Text_TimeUp_It:
    db   "tempo limite", TEXT_TERMINATOR

Text_WellDone:
    text_langs Text_WellDone_En, Text_WellDone_Fr, Text_WellDone_De, Text_WellDone_Es, Text_WellDone_It
Text_WellDone_En:
    db   "well done!", TEXT_TERMINATOR
Text_WellDone_Fr:
    db   "bien joue!", TEXT_TERMINATOR
Text_WellDone_De:
    db   "gut gemacht", TEXT_TERMINATOR
Text_WellDone_Es:   ; ¡bien hecho!
    db   "Ubien hecho!", TEXT_TERMINATOR
Text_WellDone_It:
    db   "ben fatto!", TEXT_TERMINATOR

Text_GameOver:
    text_langs Text_GameOver_En, Text_GameOver_Fr, Text_GameOver_De, Text_GameOver_Es, Text_GameOver_It
Text_GameOver_En:
    db   "game over!", TEXT_TERMINATOR
Text_GameOver_Fr:
    db   "partie terminee", TEXT_TERMINATOR
Text_GameOver_De:
    db   "game over", TEXT_TERMINATOR
Text_GameOver_Es:
    db   "fin de partida", TEXT_TERMINATOR
Text_GameOver_It:
    db   "partita finita", TEXT_TERMINATOR

Text_Resume:
    text_langs Text_Resume_En, Text_Resume_Fr, Text_Resume_De, Text_Resume_Es, Text_Resume_It
Text_Resume_En:
    db   "resume", TEXT_TERMINATOR
Text_Resume_Fr:
    db   "continuer", TEXT_TERMINATOR
Text_Resume_De:
    db   "fortfahren", TEXT_TERMINATOR
Text_Resume_Es:
    db   "continuar", TEXT_TERMINATOR
Text_Resume_It:
    db   "riprendi", TEXT_TERMINATOR

Text_Totals:
    text_langs Text_Totals_En, Text_Totals_Fr, Text_Totals_De, Text_Totals_Es, Text_Totals_It
Text_Totals_En:
    db   "totals", TEXT_TERMINATOR
Text_Totals_Fr:
    db   "totaux", TEXT_TERMINATOR
Text_Totals_De:
    db   "ergebnis", TEXT_TERMINATOR
Text_Totals_Es:
    db   "totales", TEXT_TERMINATOR
Text_Totals_It:
    db   "totali", TEXT_TERMINATOR

Text_QuitGame:
    text_langs Text_QuitGame_En, Text_QuitGame_Fr, Text_QuitGame_De, Text_QuitGame_Es, Text_QuitGame_It
Text_QuitGame_En:
    db   "quit game", TEXT_TERMINATOR
Text_QuitGame_Fr:
    db   "quitter partie", TEXT_TERMINATOR
Text_QuitGame_De:
    db   "spiel beenden", TEXT_TERMINATOR
Text_QuitGame_Es:
    db   "salir del juego", TEXT_TERMINATOR
Text_QuitGame_It:
    db   "esci dal gioco", TEXT_TERMINATOR

Text_SeePassword:
    text_langs Text_SeePassword_En, Text_SeePassword_Fr, Text_SeePassword_De, Text_SeePassword_Es, Text_SeePassword_It
Text_SeePassword_En:
    db   "see password", TEXT_TERMINATOR
Text_SeePassword_Fr:
    db   "voir mot de passe", TEXT_TERMINATOR
Text_SeePassword_De:   ; paßwort sehen
    db   "paVwort sehen", TEXT_TERMINATOR
Text_SeePassword_Es:   ; ver contraseña
    db   "ver contraseWa", TEXT_TERMINATOR
Text_SeePassword_It:
    db   "vedi password", TEXT_TERMINATOR

Text_GoToMap:
    text_langs Text_GoToMap_En, Text_GoToMap_Fr, Text_GoToMap_De, Text_GoToMap_Es, Text_GoToMap_It
Text_GoToMap_En:
    db   "go to map", TEXT_TERMINATOR
    db   $80   ; padding - no pointer reaches this byte
Text_GoToMap_Fr:
    db   "retour a la carte", TEXT_TERMINATOR
Text_GoToMap_De:
    db   "zur karte", TEXT_TERMINATOR
Text_GoToMap_Es:
    db   "volver al mapa", TEXT_TERMINATOR
Text_GoToMap_It:
    db   "ritorna alla mappa", TEXT_TERMINATOR

Text_ForgetIt:
    text_langs Text_ForgetIt_En, Text_ForgetIt_Fr, Text_ForgetIt_De, Text_ForgetIt_Es, Text_ForgetIt_It
Text_ForgetIt_En:
    db   "forget it", TEXT_TERMINATOR
Text_ForgetIt_Fr:
    db   "n'y pense meme pas!", TEXT_TERMINATOR
Text_ForgetIt_De:
    db   "vergiss es", TEXT_TERMINATOR
Text_ForgetIt_Es:   ; olvidátelo
    db   "olvidFtelo", TEXT_TERMINATOR
Text_ForgetIt_It:
    db   "lascia perdere", TEXT_TERMINATOR

Text_BadPassword:
    text_langs Text_BadPassword_En, Text_BadPassword_Fr, Text_BadPassword_De, Text_BadPassword_Es, Text_BadPassword_It
Text_BadPassword_En:
    db   "bad password", TEXT_TERMINATOR
Text_BadPassword_Fr:
    db   "mot de passe incorrect", TEXT_TERMINATOR
Text_BadPassword_De:   ; falsches paßwort
    db   "falsches paVwort", TEXT_TERMINATOR
Text_BadPassword_Es:   ; contraseña mala
    db   "contraseWa mala", TEXT_TERMINATOR
Text_BadPassword_It:
    db   "password errata", TEXT_TERMINATOR

; ------------------------------------------------------------------
; THE PASSWORD KEYBOARD
;
; The two PASSWORD_KEY_COLUMNS-wide rows drawn by menu command descriptors
; $12 and $13, written as ordinary text and drawn by the ordinary text
; renderer - the "keyboard" is two strings, not a widget. Row 1 opens with a
; backtick, which .data_01_4dfd_CharToGlyph maps to glyph 0, so cell 0 is
; the blank PASSWORD_KEY_BLANK. Between them they spell the 32 values a
; PASSWORD_BITS_PER_CELL-bit cell can hold
; ------------------------------------------------------------------

Text_PasswordKeyRow1:
    text_all_langs Text_PasswordKeyRow1_Str
Text_PasswordKeyRow1_Str:
    db   "`abcdefghijklmno", TEXT_TERMINATOR

Text_PasswordKeyRow2:
    text_all_langs Text_PasswordKeyRow2_Str
Text_PasswordKeyRow2_Str:
; NO TERMINATOR. The $DD that ends this string is the low byte of the first
; pointer of Text_CounterStrings below, which has bit 7 set and so does the
; job. The two records overlap by one byte and cannot be separated
    db   "pqrstuvwxyz01234"

; ------------------------------------------------------------------
; THE COUNTER "STRINGS"
; ------------------------------------------------------------------
Text_CounterStrings:
; Not text at all - five pointers into WRAM, one per language, all the same.
;
; call_01_470c_MenuCmd_SetCounterText formats a number into
; wDADD_MenuTextBuffer and then points the source at THIS table, so the lookup
; that would normally fetch a ROM string fetches the buffer the caller just
; filled. That is how a menu command prints a value that changes.
;
; NOTE THE FIRST BYTE. $DD has bit 7 set, so it doubles as the terminator of
; Text_PasswordKeyRow2 just above, which has none of its own. Move this table
; or change that pointer and the keyboard string runs on into whatever follows
    text_all_langs wDADD_MenuTextBuffer

; ------------------------------------------------------------------
; PER-LEVEL TEXT BLOCKS
;
; One block per level, indexed by .data_01_4b53_MapTextBlocks. Unlike the records
; above, a block puts all five of its tables together and then all of its strings,
; which is why the tables here point a long way forward.
;
;   +$00  the channel name  - call_01_4b22_MenuText_GetLevelNameTable
;   +$0A  the episode name  - call_01_4b2a_MenuText_GetTVNameTable
;   +$14  mission 1         - call_01_4b32_MenuText_GetMissionTable, index 0
;   +$1E  mission 2         - ...index 1
;   +$28  mission 3         - ...index 2
;
; Every block carries all three mission records whether or not the level has three
; missions; the spares point at empty strings - a lone TEXT_TERMINATOR - and the
; mission select screen only asks for as many as its MENU_* record says, so they
; are never drawn.
;
; The LEVEL_* constants are named after the channel for most levels but after the
; episode for LEVEL_GEXTREME_SPORTS and LEVEL_MARSUPIAL_MADNESS, whose channel
; name is "bonus bonanza" for both
; ------------------------------------------------------------------

MapText_GexCave: ; LEVEL_GEX_CAVE
MapText_GexCave_ChannelName:
    text_langs MapText_GexCave_ChannelName_En, MapText_GexCave_ChannelName_Fr, MapText_GexCave_ChannelName_De, MapText_GexCave_ChannelName_Es, MapText_GexCave_ChannelName_It
MapText_GexCave_EpisodeName:
    text_langs MapText_GexCave_EpisodeName_En, MapText_GexCave_EpisodeName_Fr, MapText_GexCave_EpisodeName_De, MapText_GexCave_EpisodeName_Es, MapText_GexCave_EpisodeName_It
MapText_GexCave_Mission1:
    text_all_langs MapText_GexCave_Mission1_Str
MapText_GexCave_Mission2:
    text_all_langs MapText_GexCave_Mission2_Str
MapText_GexCave_Mission3:
    text_all_langs MapText_GexCave_Mission3_Str
MapText_GexCave_ChannelName_En:
    db   "gex cave", TEXT_TERMINATOR
MapText_GexCave_ChannelName_Fr:
    db   "gex cave", TEXT_TERMINATOR
MapText_GexCave_ChannelName_De:   ; gex höhle
    db   "gex hDhle", TEXT_TERMINATOR
MapText_GexCave_ChannelName_Es:
    db   "cueva de gex", TEXT_TERMINATOR
MapText_GexCave_ChannelName_It:
    db   "caverna di gex", TEXT_TERMINATOR
MapText_GexCave_EpisodeName_En:
    db   "mission control", TEXT_TERMINATOR
MapText_GexCave_EpisodeName_Fr:
    db   "centre de commandes", TEXT_TERMINATOR
MapText_GexCave_EpisodeName_De:
    db   "mission control", TEXT_TERMINATOR
MapText_GexCave_EpisodeName_Es:
    db   "centro de controles", TEXT_TERMINATOR
MapText_GexCave_EpisodeName_It:
    db   "controllo missione", TEXT_TERMINATOR
MapText_GexCave_Mission1_Str:
    db   "", TEXT_TERMINATOR
MapText_GexCave_Mission2_Str:
    db   "", TEXT_TERMINATOR
MapText_GexCave_Mission3_Str:
    db   "", TEXT_TERMINATOR

MapText_HolidayTv: ; LEVEL_HOLIDAY_TV
MapText_HolidayTv_ChannelName:
    text_langs MapText_HolidayTv_ChannelName_En, MapText_HolidayTv_ChannelName_Fr, MapText_HolidayTv_ChannelName_De, MapText_HolidayTv_ChannelName_Es, MapText_HolidayTv_ChannelName_It
MapText_HolidayTv_EpisodeName:
    text_langs MapText_HolidayTv_EpisodeName_En, MapText_HolidayTv_EpisodeName_Fr, MapText_HolidayTv_EpisodeName_De, MapText_HolidayTv_EpisodeName_Es, MapText_HolidayTv_EpisodeName_It
MapText_HolidayTv_Mission1:
    text_langs MapText_HolidayTv_Mission1_En, MapText_HolidayTv_Mission1_Fr, MapText_HolidayTv_Mission1_De, MapText_HolidayTv_Mission1_Es, MapText_HolidayTv_Mission1_It
MapText_HolidayTv_Mission2:
    text_langs MapText_HolidayTv_Mission2_En, MapText_HolidayTv_Mission2_Fr, MapText_HolidayTv_Mission2_De, MapText_HolidayTv_Mission2_Es, MapText_HolidayTv_Mission2_It
MapText_HolidayTv_Mission3:
    text_langs MapText_HolidayTv_Mission3_En, MapText_HolidayTv_Mission3_Fr, MapText_HolidayTv_Mission3_De, MapText_HolidayTv_Mission3_Es, MapText_HolidayTv_Mission3_It
MapText_HolidayTv_ChannelName_En:
    db   "holiday tv", TEXT_TERMINATOR
MapText_HolidayTv_ChannelName_Fr:
    db   "tele vacances", TEXT_TERMINATOR
MapText_HolidayTv_ChannelName_De:
    db   "holiday tv", TEXT_TERMINATOR
MapText_HolidayTv_ChannelName_Es:
    db   "vacaciones tv", TEXT_TERMINATOR
MapText_HolidayTv_ChannelName_It:
    db   "speciale tv", TEXT_TERMINATOR
MapText_HolidayTv_EpisodeName_En:
    db   "totally scrooged", TEXT_TERMINATOR
MapText_HolidayTv_EpisodeName_Fr:
    db   "vieux radin", TEXT_TERMINATOR
MapText_HolidayTv_EpisodeName_De:
    db   "total plemplem", TEXT_TERMINATOR
MapText_HolidayTv_EpisodeName_Es:   ; viejo tacaño
    db   "viejo tacaWo", TEXT_TERMINATOR
MapText_HolidayTv_EpisodeName_It:
    db   "gordon gekko", TEXT_TERMINATOR
MapText_HolidayTv_Mission1_En:
    db   "create 5 ice sculptures", TEXT_TERMINATOR
MapText_HolidayTv_Mission1_Fr:
    db   "cree cinq sculptures de glace", TEXT_TERMINATOR
MapText_HolidayTv_Mission1_De:   ; bauen sie fünf eisskulpturen
    db   "bauen sie fEnf eisskulpturen", TEXT_TERMINATOR
MapText_HolidayTv_Mission1_Es:
    db   "crear cinco esculturas de hielo", TEXT_TERMINATOR
MapText_HolidayTv_Mission1_It:
    db   "realizza cinque sculture di ghiaccio", TEXT_TERMINATOR
MapText_HolidayTv_Mission2_En:
    db   "whack the 2 ice-skating elves", TEXT_TERMINATOR
MapText_HolidayTv_Mission2_Fr:
    db   "pulverise les deux elfes patineurs", TEXT_TERMINATOR
MapText_HolidayTv_Mission2_De:   ; verprügeln sie die schlittschuh-fahrenden elfen
    db   "verprEgeln sie die schlittschuh-fahrenden elfen", TEXT_TERMINATOR
MapText_HolidayTv_Mission2_Es:
    db   "pegar a los elfos que hacen patinaje", TEXT_TERMINATOR
MapText_HolidayTv_Mission2_It:
    db   "colpisci i 2 elfi sui pattini", TEXT_TERMINATOR
MapText_HolidayTv_Mission3_En:
    db   "defeat evil santa", TEXT_TERMINATOR
MapText_HolidayTv_Mission3_Fr:
    db   "pulverise le mechant pere noel", TEXT_TERMINATOR
MapText_HolidayTv_Mission3_De:   ; bekämpfen sie den bösen nikolaus
    db   "bekAmpfen sie den bDsen nikolaus", TEXT_TERMINATOR
MapText_HolidayTv_Mission3_Es:
    db   "vencer al malvado santa", TEXT_TERMINATOR
MapText_HolidayTv_Mission3_It:
    db   "sconfiggi il perfido babbo natale", TEXT_TERMINATOR

MapText_MysteryTv: ; LEVEL_MYSTERY_TV
MapText_MysteryTv_ChannelName:
    text_langs MapText_MysteryTv_ChannelName_En, MapText_MysteryTv_ChannelName_Fr, MapText_MysteryTv_ChannelName_De, MapText_MysteryTv_ChannelName_Es, MapText_MysteryTv_ChannelName_It
MapText_MysteryTv_EpisodeName:
    text_langs MapText_MysteryTv_EpisodeName_En, MapText_MysteryTv_EpisodeName_Fr, MapText_MysteryTv_EpisodeName_De, MapText_MysteryTv_EpisodeName_Es, MapText_MysteryTv_EpisodeName_It
MapText_MysteryTv_Mission1:
    text_langs MapText_MysteryTv_Mission1_En, MapText_MysteryTv_Mission1_Fr, MapText_MysteryTv_Mission1_De, MapText_MysteryTv_Mission1_Es, MapText_MysteryTv_Mission1_It
MapText_MysteryTv_Mission2:
    text_langs MapText_MysteryTv_Mission2_En, MapText_MysteryTv_Mission2_Fr, MapText_MysteryTv_Mission2_De, MapText_MysteryTv_Mission2_Es, MapText_MysteryTv_Mission2_It
MapText_MysteryTv_Mission3:
    text_langs MapText_MysteryTv_Mission3_En, MapText_MysteryTv_Mission3_Fr, MapText_MysteryTv_Mission3_De, MapText_MysteryTv_Mission3_Es, MapText_MysteryTv_Mission3_It
MapText_MysteryTv_ChannelName_En:
    db   "mystery tv", TEXT_TERMINATOR
MapText_MysteryTv_ChannelName_Fr:
    db   "tele mysteres", TEXT_TERMINATOR
MapText_MysteryTv_ChannelName_De:
    db   "mystery tv", TEXT_TERMINATOR
MapText_MysteryTv_ChannelName_Es:
    db   "misterio tv", TEXT_TERMINATOR
MapText_MysteryTv_ChannelName_It:
    db   "misteri tv", TEXT_TERMINATOR
MapText_MysteryTv_EpisodeName_En:
    db   "clueless in seattle", TEXT_TERMINATOR
MapText_MysteryTv_EpisodeName_Fr:
    db   "perdu dans la nuit a seattle", TEXT_TERMINATOR
MapText_MysteryTv_EpisodeName_De:
    db   "ratlos in seattle", TEXT_TERMINATOR
MapText_MysteryTv_EpisodeName_Es:
    db   "perdido en seattle", TEXT_TERMINATOR
MapText_MysteryTv_EpisodeName_It:
    db   "insonnia a seattle", TEXT_TERMINATOR
MapText_MysteryTv_Mission1_En:
    db   "survive the hedge maze", TEXT_TERMINATOR
MapText_MysteryTv_Mission1_Fr:
    db   "sors vivant du labyrinthe", TEXT_TERMINATOR
MapText_MysteryTv_Mission1_De:   ; überstehen sie das heckenlabyrinth
    db   "Eberstehen sie das heckenlabyrinth", TEXT_TERMINATOR
MapText_MysteryTv_Mission1_Es:
    db   "sobrevive al laberinto de setos", TEXT_TERMINATOR
MapText_MysteryTv_Mission1_It:
    db   "sopravvivi al labirinto di siepi", TEXT_TERMINATOR
MapText_MysteryTv_Mission2_En:
    db   "break three blood coolers", TEXT_TERMINATOR
MapText_MysteryTv_Mission2_Fr:
    db   "degomme les trois frigos!", TEXT_TERMINATOR
MapText_MysteryTv_Mission2_De:   ; zerbrechen sie drei blutkühler!
    db   "zerbrechen sie drei blutkEhler!", TEXT_TERMINATOR
MapText_MysteryTv_Mission2_Es:   ; ¡rompe los tres refrigeradores de sangre!
    db   "Urompe los tres refrigeradores de sangre!", TEXT_TERMINATOR
MapText_MysteryTv_Mission2_It:
    db   "sfonda i tre raffreddatori a sangue, di nuovo!", TEXT_TERMINATOR
MapText_MysteryTv_Mission3_En:
    db   "steal the magic sword from the ghost knight", TEXT_TERMINATOR
MapText_MysteryTv_Mission3_Fr:
    db   "vole l'epee magique du chevalier fantome", TEXT_TERMINATOR
MapText_MysteryTv_Mission3_De:
    db   "stehlen sie dem geistritter das magische schwert", TEXT_TERMINATOR
MapText_MysteryTv_Mission3_Es:   ; rueba la espada mágico del caballero fantasma
    db   "rueba la espada mFgico del caballero fantasma", TEXT_TERMINATOR
MapText_MysteryTv_Mission3_It:
    db   "ruba la spada magica del cavaliere fantasma", TEXT_TERMINATOR

MapText_TutTv: ; LEVEL_TUT_TV
MapText_TutTv_ChannelName:
    text_langs MapText_TutTv_ChannelName_En, MapText_TutTv_ChannelName_Fr, MapText_TutTv_ChannelName_De, MapText_TutTv_ChannelName_Es, MapText_TutTv_ChannelName_It
MapText_TutTv_EpisodeName:
    text_langs MapText_TutTv_EpisodeName_En, MapText_TutTv_EpisodeName_Fr, MapText_TutTv_EpisodeName_De, MapText_TutTv_EpisodeName_Es, MapText_TutTv_EpisodeName_It
MapText_TutTv_Mission1:
    text_langs MapText_TutTv_Mission1_En, MapText_TutTv_Mission1_Fr, MapText_TutTv_Mission1_De, MapText_TutTv_Mission1_Es, MapText_TutTv_Mission1_It
MapText_TutTv_Mission2:
    text_langs MapText_TutTv_Mission2_En, MapText_TutTv_Mission2_Fr, MapText_TutTv_Mission2_De, MapText_TutTv_Mission2_Es, MapText_TutTv_Mission2_It
MapText_TutTv_Mission3:
    text_langs MapText_TutTv_Mission3_En, MapText_TutTv_Mission3_Fr, MapText_TutTv_Mission3_De, MapText_TutTv_Mission3_Es, MapText_TutTv_Mission3_It
MapText_TutTv_ChannelName_En:
    db   "tut tv", TEXT_TERMINATOR
MapText_TutTv_ChannelName_Fr:
    db   "tv sphinx", TEXT_TERMINATOR
MapText_TutTv_ChannelName_De:
    db   "tut tv", TEXT_TERMINATOR
MapText_TutTv_ChannelName_Es:
    db   "tut tv", TEXT_TERMINATOR
MapText_TutTv_ChannelName_It:
    db   "tut tv", TEXT_TERMINATOR
MapText_TutTv_EpisodeName_En:
    db   "holy moses!", TEXT_TERMINATOR
MapText_TutTv_EpisodeName_Fr:
    db   "sacre moise!", TEXT_TERMINATOR
MapText_TutTv_EpisodeName_De:
    db   "heiliger moses!", TEXT_TERMINATOR
MapText_TutTv_EpisodeName_Es:   ; ¡dios bendito!
    db   "Udios bendito!", TEXT_TERMINATOR
MapText_TutTv_EpisodeName_It:   ; per la barba di mosè!
    db   "per la barba di mosL!", TEXT_TERMINATOR
MapText_TutTv_Mission1_En:
    db   "recover the 3 staffs of ra", TEXT_TERMINATOR
MapText_TutTv_Mission1_Fr:
    db   "retrouve les 3 sceptres de ra", TEXT_TERMINATOR
MapText_TutTv_Mission1_De:   ; finden sie die 3 stäbe des rah
    db   "finden sie die 3 stAbe des rah", TEXT_TERMINATOR
MapText_TutTv_Mission1_Es:   ; recupera los 3 báculos de rah
    db   "recupera los 3 bFculos de rah", TEXT_TERMINATOR
MapText_TutTv_Mission1_It:
    db   "recupera le 3 staffe di rah", TEXT_TERMINATOR
MapText_TutTv_Mission2_En:
    db   "release the spirits from the 3 lost arks", TEXT_TERMINATOR
MapText_TutTv_Mission2_Fr:
    db   "libere les esprits des trois arches perdues", TEXT_TERMINATOR
MapText_TutTv_Mission2_De:
    db   "befreien sie die geister aus den 3 schreinen", TEXT_TERMINATOR
MapText_TutTv_Mission2_Es:   ; suelta a los espíritus de tres arcas pedidas
    db   "suelta a los espHritus de tres arcas pedidas", TEXT_TERMINATOR
MapText_TutTv_Mission2_It:
    db   "libera gli spiriti delle tre arche perdute", TEXT_TERMINATOR
MapText_TutTv_Mission3_En:
    db   "ride the raft into the ancient temple", TEXT_TERMINATOR
MapText_TutTv_Mission3_Fr:
    db   "mene le radeau dans le vieux temple", TEXT_TERMINATOR
MapText_TutTv_Mission3_De:   ; fahren sie auf dem floß in den alten tempel
    db   "fahren sie auf dem floV in den alten tempel", TEXT_TERMINATOR
MapText_TutTv_Mission3_Es:
    db   "veta en balsa al templo antiguo", TEXT_TERMINATOR
MapText_TutTv_Mission3_It:
    db   "guida la zattera nel tempio antico", TEXT_TERMINATOR

MapText_WesternStation: ; LEVEL_WESTERN_STATION
MapText_WesternStation_ChannelName:
    text_langs MapText_WesternStation_ChannelName_En, MapText_WesternStation_ChannelName_Fr, MapText_WesternStation_ChannelName_De, MapText_WesternStation_ChannelName_Es, MapText_WesternStation_ChannelName_It
MapText_WesternStation_EpisodeName:
    text_langs MapText_WesternStation_EpisodeName_En, MapText_WesternStation_EpisodeName_Fr, MapText_WesternStation_EpisodeName_De, MapText_WesternStation_EpisodeName_Es, MapText_WesternStation_EpisodeName_It
MapText_WesternStation_Mission1:
    text_langs MapText_WesternStation_Mission1_En, MapText_WesternStation_Mission1_Fr, MapText_WesternStation_Mission1_De, MapText_WesternStation_Mission1_Es, MapText_WesternStation_Mission1_It
MapText_WesternStation_Mission2:
    text_langs MapText_WesternStation_Mission2_En, MapText_WesternStation_Mission2_Fr, MapText_WesternStation_Mission2_De, MapText_WesternStation_Mission2_Es, MapText_WesternStation_Mission2_It
MapText_WesternStation_Mission3:
    text_langs MapText_WesternStation_Mission3_En, MapText_WesternStation_Mission3_Fr, MapText_WesternStation_Mission3_De, MapText_WesternStation_Mission3_Es, MapText_WesternStation_Mission3_It
MapText_WesternStation_ChannelName_En:
    db   "western station", TEXT_TERMINATOR
MapText_WesternStation_ChannelName_Fr:
    db   "tele far west", TEXT_TERMINATOR
MapText_WesternStation_ChannelName_De:
    db   "western station", TEXT_TERMINATOR
MapText_WesternStation_ChannelName_Es:
    db   "puesto del oeste", TEXT_TERMINATOR
MapText_WesternStation_ChannelName_It:
    db   "stazione occidentale", TEXT_TERMINATOR
MapText_WesternStation_EpisodeName_En:
    db   "the organ trail", TEXT_TERMINATOR
MapText_WesternStation_EpisodeName_Fr:
    db   "corps en stock", TEXT_TERMINATOR
MapText_WesternStation_EpisodeName_De:
    db   "die blutspur", TEXT_TERMINATOR
MapText_WesternStation_EpisodeName_Es:
    db   "caravana de colonos", TEXT_TERMINATOR
MapText_WesternStation_EpisodeName_It:
    db   "impronta dell'organo", TEXT_TERMINATOR
MapText_WesternStation_Mission1_En:
    db   "visit the world's largest mound of poop", TEXT_TERMINATOR
MapText_WesternStation_Mission1_Fr:
    db   "visite la plus grande caca du monde", TEXT_TERMINATOR
MapText_WesternStation_Mission1_De:   ; besuchen sie den größten misthaufen der welt
    db   "besuchen sie den grDVten misthaufen der welt", TEXT_TERMINATOR
MapText_WesternStation_Mission1_Es:   ; visitar el montón de caca más grande del mundo
    db   "visitar el montIn de caca mFs grande del mundo", TEXT_TERMINATOR
MapText_WesternStation_Mission1_It:   ; la più grande poppa del mondo
    db   "la piO grande poppa del mondo", TEXT_TERMINATOR
MapText_WesternStation_Mission2_En:
    db   "collect 5 of a kind", TEXT_TERMINATOR
MapText_WesternStation_Mission2_Fr:
    db   "trouves-en 5 pareils", TEXT_TERMINATOR
MapText_WesternStation_Mission2_De:
    db   "sammeln sie funf von einer art", TEXT_TERMINATOR
MapText_WesternStation_Mission2_Es:
    db   "recoge cinco de la misma clase", TEXT_TERMINATOR
MapText_WesternStation_Mission2_It:
    db   "collezionane 5 per tipo", TEXT_TERMINATOR
MapText_WesternStation_Mission3_En:
    db   "survive the old mine", TEXT_TERMINATOR
MapText_WesternStation_Mission3_Fr:
    db   "sortez vivant de la mine d'or", TEXT_TERMINATOR
MapText_WesternStation_Mission3_De:   ; überlebe die alte mine
    db   "Eberlebe die alte mine", TEXT_TERMINATOR
MapText_WesternStation_Mission3_Es:
    db   "sobrevive a la vieja mina", TEXT_TERMINATOR
MapText_WesternStation_Mission3_It:
    db   "sopravvivi nella vecchia miniera", TEXT_TERMINATOR

MapText_AnimeChannel: ; LEVEL_ANIME_CHANNEL
MapText_AnimeChannel_ChannelName:
    text_langs MapText_AnimeChannel_ChannelName_En, MapText_AnimeChannel_ChannelName_Fr, MapText_AnimeChannel_ChannelName_De, MapText_AnimeChannel_ChannelName_Es, MapText_AnimeChannel_ChannelName_It
MapText_AnimeChannel_EpisodeName:
    text_langs MapText_AnimeChannel_EpisodeName_En, MapText_AnimeChannel_EpisodeName_Fr, MapText_AnimeChannel_EpisodeName_De, MapText_AnimeChannel_EpisodeName_Es, MapText_AnimeChannel_EpisodeName_It
MapText_AnimeChannel_Mission1:
    text_langs MapText_AnimeChannel_Mission1_En, MapText_AnimeChannel_Mission1_Fr, MapText_AnimeChannel_Mission1_De, MapText_AnimeChannel_Mission1_Es, MapText_AnimeChannel_Mission1_It
MapText_AnimeChannel_Mission2:
    text_langs MapText_AnimeChannel_Mission2_En, MapText_AnimeChannel_Mission2_Fr, MapText_AnimeChannel_Mission2_De, MapText_AnimeChannel_Mission2_Es, MapText_AnimeChannel_Mission2_It
MapText_AnimeChannel_Mission3:
    text_langs MapText_AnimeChannel_Mission3_En, MapText_AnimeChannel_Mission3_Fr, MapText_AnimeChannel_Mission3_De, MapText_AnimeChannel_Mission3_Es, MapText_AnimeChannel_Mission3_It
MapText_AnimeChannel_ChannelName_En:
    db   "anime channel", TEXT_TERMINATOR
MapText_AnimeChannel_ChannelName_Fr:
    db   "anime channel", TEXT_TERMINATOR
MapText_AnimeChannel_ChannelName_De:
    db   "zeichentrick tv", TEXT_TERMINATOR
MapText_AnimeChannel_ChannelName_Es:
    db   "canal anime", TEXT_TERMINATOR
MapText_AnimeChannel_ChannelName_It:
    db   "canale anime", TEXT_TERMINATOR
MapText_AnimeChannel_EpisodeName_En:
    db   "when sushi goes bad", TEXT_TERMINATOR
MapText_AnimeChannel_EpisodeName_Fr:
    db   "l'annee de tous les sushis", TEXT_TERMINATOR
MapText_AnimeChannel_EpisodeName_De:   ; wenn alles zu spät ist
    db   "wenn alles zu spAt ist", TEXT_TERMINATOR
MapText_AnimeChannel_EpisodeName_Es:
    db   "cuando el sushi se estropea", TEXT_TERMINATOR
MapText_AnimeChannel_EpisodeName_It:
    db   "quando il sushi va a male", TEXT_TERMINATOR
MapText_AnimeChannel_Mission1_En:
    db   "destroy the 3 alien culture tubes", TEXT_TERMINATOR
MapText_AnimeChannel_Mission1_Fr:
    db   "detruis les trois tubes de protoculture", TEXT_TERMINATOR
MapText_AnimeChannel_Mission1_De:
    db   "vernichten sie die drei aliens", TEXT_TERMINATOR
MapText_AnimeChannel_Mission1_Es:
    db   "demole los tres tubos de cultura extraterrestre", TEXT_TERMINATOR
MapText_AnimeChannel_Mission1_It:
    db   "demolisci le tre capsule di contenimento", TEXT_TERMINATOR
MapText_AnimeChannel_Mission2_En:
    db   "deactivate the 'planet-o-blast' weapon", TEXT_TERMINATOR
MapText_AnimeChannel_Mission2_Fr:
    db   "desactive le blaster de planetes", TEXT_TERMINATOR
MapText_AnimeChannel_Mission2_De:
    db   "deaktivieren sie die 'planeten killer' waffe", TEXT_TERMINATOR
MapText_AnimeChannel_Mission2_Es:
    db   "desactiva la arma de 'planet-o-blast'", TEXT_TERMINATOR
MapText_AnimeChannel_Mission2_It:
    db   "disattiva l'arma 'planet-o-blast'", TEXT_TERMINATOR
MapText_AnimeChannel_Mission3_En:
    db   "find and destroy the rogue mechs", TEXT_TERMINATOR
MapText_AnimeChannel_Mission3_Fr:
    db   "trouve et liquide le bandit mecanique", TEXT_TERMINATOR
MapText_AnimeChannel_Mission3_De:
    db   "geben sie den robotern den rest", TEXT_TERMINATOR
MapText_AnimeChannel_Mission3_Es:   ; encontra y destruye a los mecánicos granujas
    db   "encontra y destruye a los mecFnicos granujas", TEXT_TERMINATOR
MapText_AnimeChannel_Mission3_It:
    db   "trova e distruggi i robot traditori", TEXT_TERMINATOR

MapText_SuperheroShow: ; LEVEL_SUPERHERO_SHOW
MapText_SuperheroShow_ChannelName:
    text_langs MapText_SuperheroShow_ChannelName_En, MapText_SuperheroShow_ChannelName_Fr, MapText_SuperheroShow_ChannelName_De, MapText_SuperheroShow_ChannelName_Es, MapText_SuperheroShow_ChannelName_It
MapText_SuperheroShow_EpisodeName:
    text_langs MapText_SuperheroShow_EpisodeName_En, MapText_SuperheroShow_EpisodeName_Fr, MapText_SuperheroShow_EpisodeName_De, MapText_SuperheroShow_EpisodeName_Es, MapText_SuperheroShow_EpisodeName_It
MapText_SuperheroShow_Mission1:
    text_langs MapText_SuperheroShow_Mission1_En, MapText_SuperheroShow_Mission1_Fr, MapText_SuperheroShow_Mission1_De, MapText_SuperheroShow_Mission1_Es, MapText_SuperheroShow_Mission1_It
MapText_SuperheroShow_Mission2:
    text_langs MapText_SuperheroShow_Mission2_En, MapText_SuperheroShow_Mission2_Fr, MapText_SuperheroShow_Mission2_De, MapText_SuperheroShow_Mission2_Es, MapText_SuperheroShow_Mission2_It
MapText_SuperheroShow_Mission3:
    text_langs MapText_SuperheroShow_Mission3_En, MapText_SuperheroShow_Mission3_Fr, MapText_SuperheroShow_Mission3_De, MapText_SuperheroShow_Mission3_Es, MapText_SuperheroShow_Mission3_It
MapText_SuperheroShow_ChannelName_En:
    db   "superhero show", TEXT_TERMINATOR
MapText_SuperheroShow_ChannelName_Fr:
    db   "la nuit des superheros", TEXT_TERMINATOR
MapText_SuperheroShow_ChannelName_De:
    db   "superstar show", TEXT_TERMINATOR
MapText_SuperheroShow_ChannelName_Es:
    db   "tv del superheroe", TEXT_TERMINATOR
MapText_SuperheroShow_ChannelName_It:
    db   "show del supereroe", TEXT_TERMINATOR
MapText_SuperheroShow_EpisodeName_En:
    db   "superzeroes", TEXT_TERMINATOR
MapText_SuperheroShow_EpisodeName_Fr:
    db   "super zeros", TEXT_TERMINATOR
MapText_SuperheroShow_EpisodeName_De:
    db   "supernullen", TEXT_TERMINATOR
MapText_SuperheroShow_EpisodeName_Es:   ; superzéroes
    db   "superzGroes", TEXT_TERMINATOR
MapText_SuperheroShow_EpisodeName_It:
    db   "superzeroi", TEXT_TERMINATOR
MapText_SuperheroShow_Mission1_En:
    db   "defeat the mad bomber", TEXT_TERMINATOR
MapText_SuperheroShow_Mission1_Fr:
    db   "bats le bombeur fou", TEXT_TERMINATOR
MapText_SuperheroShow_Mission1_De:   ; bekämpfen sie den verrúckten bomber
    db   "bekAmpfen sie den verrJckten bomber", TEXT_TERMINATOR
MapText_SuperheroShow_Mission1_Es:
    db   "vence al bombardero loco", TEXT_TERMINATOR
MapText_SuperheroShow_Mission1_It:
    db   "sconfiggi il bombardiere folle", TEXT_TERMINATOR
MapText_SuperheroShow_Mission2_En:
    db   "rescue 3 stray cats", TEXT_TERMINATOR
MapText_SuperheroShow_Mission2_Fr:
    db   "ramasse trois chats errants", TEXT_TERMINATOR
MapText_SuperheroShow_Mission2_De:
    db   "retten sie drei streunenden katzen", TEXT_TERMINATOR
MapText_SuperheroShow_Mission2_Es:
    db   "rescata a los tres gatos callejeros", TEXT_TERMINATOR
MapText_SuperheroShow_Mission2_It:
    db   "acciuffa i 3 gatti randagi", TEXT_TERMINATOR
MapText_SuperheroShow_Mission3_En:
    db   "find the 5 escaped convicts", TEXT_TERMINATOR
MapText_SuperheroShow_Mission3_Fr:
    db   "retrouve les cinq evades", TEXT_TERMINATOR
MapText_SuperheroShow_Mission3_De:   ; finden sie die 5 entflohenen sträflinge
    db   "finden sie die 5 entflohenen strAflinge", TEXT_TERMINATOR
MapText_SuperheroShow_Mission3_Es:
    db   "encuentra a los cinco convictos huidos", TEXT_TERMINATOR
MapText_SuperheroShow_Mission3_It:
    db   "trova i 5 carcerati evasi", TEXT_TERMINATOR

MapText_GextremeSports: ; LEVEL_GEXTREME_SPORTS
MapText_GextremeSports_ChannelName:
    text_langs MapText_GextremeSports_ChannelName_En, MapText_GextremeSports_ChannelName_Fr, MapText_GextremeSports_ChannelName_De, MapText_GextremeSports_ChannelName_Es, MapText_GextremeSports_ChannelName_It
MapText_GextremeSports_EpisodeName:
    text_langs MapText_GextremeSports_EpisodeName_En, MapText_GextremeSports_EpisodeName_Fr, MapText_GextremeSports_EpisodeName_De, MapText_GextremeSports_EpisodeName_Es, MapText_GextremeSports_EpisodeName_It
MapText_GextremeSports_Mission1:
    text_langs MapText_GextremeSports_Mission1_En, MapText_GextremeSports_Mission1_Fr, MapText_GextremeSports_Mission1_De, MapText_GextremeSports_Mission1_Es, MapText_GextremeSports_Mission1_It
MapText_GextremeSports_Mission2:
    text_all_langs MapText_GextremeSports_Mission2_Str
MapText_GextremeSports_Mission3:
    text_all_langs MapText_GextremeSports_Mission3_Str
MapText_GextremeSports_ChannelName_En:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_GextremeSports_ChannelName_Fr:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_GextremeSports_ChannelName_De:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_GextremeSports_ChannelName_Es:   ; festival de bonificación
    db   "festival de bonificaciIn", TEXT_TERMINATOR
MapText_GextremeSports_ChannelName_It:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_GextremeSports_EpisodeName_En:
    db   "gextreme sports", TEXT_TERMINATOR
MapText_GextremeSports_EpisodeName_Fr:   ; sports gextrêmes
    db   "sports gextrQmes", TEXT_TERMINATOR
MapText_GextremeSports_EpisodeName_De:
    db   "gextrem-sport", TEXT_TERMINATOR
MapText_GextremeSports_EpisodeName_Es:
    db   "deportes gextremos", TEXT_TERMINATOR
MapText_GextremeSports_EpisodeName_It:
    db   "sport gextremo", TEXT_TERMINATOR
MapText_GextremeSports_Mission1_En:
    db   "whack the 5 elves", TEXT_TERMINATOR
MapText_GextremeSports_Mission1_Fr:
    db   "debarrasse-toi des 5 elfes", TEXT_TERMINATOR
MapText_GextremeSports_Mission1_De:   ; verprügeln sie die 5 elfen
    db   "verprEgeln sie die 5 elfen", TEXT_TERMINATOR
MapText_GextremeSports_Mission1_Es:
    db   "pega de los 5 elfos", TEXT_TERMINATOR
MapText_GextremeSports_Mission1_It:
    db   "schiaffeggia i 5 elfi", TEXT_TERMINATOR
MapText_GextremeSports_Mission2_Str:
    db   "", TEXT_TERMINATOR
MapText_GextremeSports_Mission3_Str:
    db   "", TEXT_TERMINATOR

MapText_MarsupialMadness: ; LEVEL_MARSUPIAL_MADNESS
MapText_MarsupialMadness_ChannelName:
    text_langs MapText_MarsupialMadness_ChannelName_En, MapText_MarsupialMadness_ChannelName_Fr, MapText_MarsupialMadness_ChannelName_De, MapText_MarsupialMadness_ChannelName_Es, MapText_MarsupialMadness_ChannelName_It
MapText_MarsupialMadness_EpisodeName:
    text_langs MapText_MarsupialMadness_EpisodeName_En, MapText_MarsupialMadness_EpisodeName_Fr, MapText_MarsupialMadness_EpisodeName_De, MapText_MarsupialMadness_EpisodeName_Es, MapText_MarsupialMadness_EpisodeName_It
MapText_MarsupialMadness_Mission1:
    text_langs MapText_MarsupialMadness_Mission1_En, MapText_MarsupialMadness_Mission1_Fr, MapText_MarsupialMadness_Mission1_De, MapText_MarsupialMadness_Mission1_Es, MapText_MarsupialMadness_Mission1_It
MapText_MarsupialMadness_Mission2:
    text_all_langs MapText_MarsupialMadness_Mission2_Str
MapText_MarsupialMadness_Mission3:
    text_all_langs MapText_MarsupialMadness_Mission3_Str
MapText_MarsupialMadness_ChannelName_En:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_MarsupialMadness_ChannelName_Fr:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_MarsupialMadness_ChannelName_De:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_MarsupialMadness_ChannelName_Es:   ; festival de bonificación
    db   "festival de bonificaciIn", TEXT_TERMINATOR
MapText_MarsupialMadness_ChannelName_It:
    db   "bonus bonanza", TEXT_TERMINATOR
MapText_MarsupialMadness_EpisodeName_En:
    db   "marsupial madness", TEXT_TERMINATOR
MapText_MarsupialMadness_EpisodeName_Fr:
    db   "la folle histoire des marsupiaux", TEXT_TERMINATOR
MapText_MarsupialMadness_EpisodeName_De:
    db   "totaler wahnsinn", TEXT_TERMINATOR
MapText_MarsupialMadness_EpisodeName_Es:
    db   "locura marsupial", TEXT_TERMINATOR
MapText_MarsupialMadness_EpisodeName_It:
    db   "follia marsupiale", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission1_En:
    db   "ring the 7 bells", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission1_Fr:
    db   "fais sonner les 7 cloches", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission1_De:   ; läuten sie die 7 glocken
    db   "lAuten sie die 7 glocken", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission1_Es:
    db   "toca los 7 timbres", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission1_It:
    db   "suona le 7 campane", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission2_Str:
    db   "", TEXT_TERMINATOR
MapText_MarsupialMadness_Mission3_Str:
    db   "", TEXT_TERMINATOR

MapText_WwGexWrestling: ; LEVEL_WW_GEX_WRESTLING
MapText_WwGexWrestling_ChannelName:
    text_langs MapText_WwGexWrestling_ChannelName_En, MapText_WwGexWrestling_ChannelName_Fr, MapText_WwGexWrestling_ChannelName_De, MapText_WwGexWrestling_ChannelName_Es, MapText_WwGexWrestling_ChannelName_It
MapText_WwGexWrestling_EpisodeName:
    text_langs MapText_WwGexWrestling_EpisodeName_En, MapText_WwGexWrestling_EpisodeName_Fr, MapText_WwGexWrestling_EpisodeName_De, MapText_WwGexWrestling_EpisodeName_Es, MapText_WwGexWrestling_EpisodeName_It
MapText_WwGexWrestling_Mission1:
    text_langs MapText_WwGexWrestling_Mission1_En, MapText_WwGexWrestling_Mission1_Fr, MapText_WwGexWrestling_Mission1_De, MapText_WwGexWrestling_Mission1_Es, MapText_WwGexWrestling_Mission1_It
MapText_WwGexWrestling_Mission2:
    text_all_langs MapText_WwGexWrestling_Mission2_Str
MapText_WwGexWrestling_Mission3:
    text_all_langs MapText_WwGexWrestling_Mission3_Str
MapText_WwGexWrestling_ChannelName_En:
    db   "wwgex wrestling", TEXT_TERMINATOR
MapText_WwGexWrestling_ChannelName_Fr:
    db   "wwgex catch", TEXT_TERMINATOR
MapText_WwGexWrestling_ChannelName_De:
    db   "wwgex wrestling", TEXT_TERMINATOR
MapText_WwGexWrestling_ChannelName_Es:
    db   "lucha wwgex", TEXT_TERMINATOR
MapText_WwGexWrestling_ChannelName_It:
    db   "wrestling wwgex", TEXT_TERMINATOR
MapText_WwGexWrestling_EpisodeName_En:
    db   "invasion of the body slammers", TEXT_TERMINATOR
MapText_WwGexWrestling_EpisodeName_Fr:
    db   "l'invasion venait de rez", TEXT_TERMINATOR
MapText_WwGexWrestling_EpisodeName_De:   ; invasion der körperfresser
    db   "invasion der kDrperfresser", TEXT_TERMINATOR
MapText_WwGexWrestling_EpisodeName_Es:   ; invasión de los vapuleadores de cuerpos
    db   "invasiIn de los vapuleadores de cuerpos", TEXT_TERMINATOR
MapText_WwGexWrestling_EpisodeName_It:
    db   "l'invasione dei lucertocorpi", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission1_En:
    db   "muscle flexing can be hazardous to one's health", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission1_Fr:
    db   "l'exercice peut etre dangereux pour votre sante", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission1_De:
    db   "bewegung schadet der gesundheit", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission1_Es:   ; la flexión de músculos puede ser prejudicial para la salud
    db   "la flexiIn de mJsculos puede ser prejudicial para la salud", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission1_It:   ; lo stretching può essere dannoso per la tua salute
    db   "lo stretching puN essere dannoso per la tua salute", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission2_Str:
    db   "", TEXT_TERMINATOR
MapText_WwGexWrestling_Mission3_Str:
    db   "", TEXT_TERMINATOR

MapText_LizardOfOz: ; LEVEL_LIZARD_OF_OZ
MapText_LizardOfOz_ChannelName:
    text_langs MapText_LizardOfOz_ChannelName_En, MapText_LizardOfOz_ChannelName_Fr, MapText_LizardOfOz_ChannelName_De, MapText_LizardOfOz_ChannelName_Es, MapText_LizardOfOz_ChannelName_It
MapText_LizardOfOz_EpisodeName:
    text_langs MapText_LizardOfOz_EpisodeName_En, MapText_LizardOfOz_EpisodeName_Fr, MapText_LizardOfOz_EpisodeName_De, MapText_LizardOfOz_EpisodeName_Es, MapText_LizardOfOz_EpisodeName_It
MapText_LizardOfOz_Mission1:
    text_langs MapText_LizardOfOz_Mission1_En, MapText_LizardOfOz_Mission1_Fr, MapText_LizardOfOz_Mission1_De, MapText_LizardOfOz_Mission1_Es, MapText_LizardOfOz_Mission1_It
MapText_LizardOfOz_Mission2:
    text_all_langs MapText_LizardOfOz_Mission2_Str
MapText_LizardOfOz_Mission3:
    text_all_langs MapText_LizardOfOz_Mission3_Str
MapText_LizardOfOz_ChannelName_En:
    db   "lizard of oz", TEXT_TERMINATOR
MapText_LizardOfOz_ChannelName_Fr:
    db   "ozons!", TEXT_TERMINATOR
MapText_LizardOfOz_ChannelName_De:
    db   "lizard von oz", TEXT_TERMINATOR
MapText_LizardOfOz_ChannelName_Es:
    db   "lagarto de oz", TEXT_TERMINATOR
MapText_LizardOfOz_ChannelName_It:
    db   "lucertola di oz", TEXT_TERMINATOR
MapText_LizardOfOz_EpisodeName_En:
    db   "lions, tigers and gex", TEXT_TERMINATOR
MapText_LizardOfOz_EpisodeName_Fr:
    db   "des lions, des tigres, et gex", TEXT_TERMINATOR
MapText_LizardOfOz_EpisodeName_De:   ; löwen, tiger und gex
    db   "lDwen, tiger und gex", TEXT_TERMINATOR
MapText_LizardOfOz_EpisodeName_Es:
    db   "leones, tigres y gex", TEXT_TERMINATOR
MapText_LizardOfOz_EpisodeName_It:
    db   "tigri, leoni e... gex", TEXT_TERMINATOR
MapText_LizardOfOz_Mission1_En:
    db   "watch out for pesky rezlings", TEXT_TERMINATOR
MapText_LizardOfOz_Mission1_Fr:
    db   "attention aux rezlings sournois", TEXT_TERMINATOR
MapText_LizardOfOz_Mission1_De:
    db   "halten sie ausschau nach verteufelten rezlingen", TEXT_TERMINATOR
MapText_LizardOfOz_Mission1_Es:
    db   "cuidado con los rezlitos demoniacos", TEXT_TERMINATOR
MapText_LizardOfOz_Mission1_It:
    db   "attenzione ai rezling demoniaci", TEXT_TERMINATOR
MapText_LizardOfOz_Mission2_Str:
    db   "", TEXT_TERMINATOR
MapText_LizardOfOz_Mission3_Str:
    db   "", TEXT_TERMINATOR

MapText_ChannelZ: ; LEVEL_CHANNEL_Z
MapText_ChannelZ_ChannelName:
    text_langs MapText_ChannelZ_ChannelName_En, MapText_ChannelZ_ChannelName_Fr, MapText_ChannelZ_ChannelName_De, MapText_ChannelZ_ChannelName_Es, MapText_ChannelZ_ChannelName_It
MapText_ChannelZ_EpisodeName:
    text_langs MapText_ChannelZ_EpisodeName_En, MapText_ChannelZ_EpisodeName_Fr, MapText_ChannelZ_EpisodeName_De, MapText_ChannelZ_EpisodeName_Es, MapText_ChannelZ_EpisodeName_It
MapText_ChannelZ_Mission1:
    text_langs MapText_ChannelZ_Mission1_En, MapText_ChannelZ_Mission1_Fr, MapText_ChannelZ_Mission1_De, MapText_ChannelZ_Mission1_Es, MapText_ChannelZ_Mission1_It
MapText_ChannelZ_Mission2:
    text_all_langs MapText_ChannelZ_Mission2_Str
MapText_ChannelZ_Mission3:
    text_all_langs MapText_ChannelZ_Mission3_Str
MapText_ChannelZ_ChannelName_En:
    db   "boss tv", TEXT_TERMINATOR
MapText_ChannelZ_ChannelName_Fr:
    db   "tele du boss", TEXT_TERMINATOR
MapText_ChannelZ_ChannelName_De:
    db   "boss tv", TEXT_TERMINATOR
MapText_ChannelZ_ChannelName_Es:
    db   "tv del jefe", TEXT_TERMINATOR
MapText_ChannelZ_ChannelName_It:
    db   "tv del boss", TEXT_TERMINATOR
MapText_ChannelZ_EpisodeName_En:
    db   "rez-raker", TEXT_TERMINATOR
MapText_ChannelZ_EpisodeName_Fr:
    db   "rez-raker", TEXT_TERMINATOR
MapText_ChannelZ_EpisodeName_De:
    db   "rez-ession", TEXT_TERMINATOR
MapText_ChannelZ_EpisodeName_Es:
    db   "rastrillador rez", TEXT_TERMINATOR
MapText_ChannelZ_EpisodeName_It:
    db   "rez-raker", TEXT_TERMINATOR
MapText_ChannelZ_Mission1_En:
    db   "defeat rez in the final battle", TEXT_TERMINATOR
MapText_ChannelZ_Mission1_Fr:
    db   "elimine rez dans l'ultime combat", TEXT_TERMINATOR
MapText_ChannelZ_Mission1_De:
    db   "schlagen sie rez im letzten kampf", TEXT_TERMINATOR
MapText_ChannelZ_Mission1_Es:
    db   "derrote a rez en la ultima battalla", TEXT_TERMINATOR
MapText_ChannelZ_Mission1_It:
    db   "sconfiggete rez nella battaglia finale", TEXT_TERMINATOR
MapText_ChannelZ_Mission2_Str:
    db   "", TEXT_TERMINATOR
MapText_ChannelZ_Mission3_Str:
    db   "", TEXT_TERMINATOR

