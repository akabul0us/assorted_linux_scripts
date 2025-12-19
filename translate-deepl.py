#!/usr/bin/env python3
import deepl
import sys
import argparse
from pathlib import Path
home = Path.home()
try:
    with open(home / ".deepl_auth_key", 'r') as file:
        deepl_auth_key = file.read().rstrip()
    #rstrip ensures it doesn't get confused by a newline character
except OSError:
    print('\033[31;1m', end='')
    print ('You need a DeepL API auth key to use this script.')
    print('\x1b[0m', end='')
    print ('Please store your key as a text file in your home directory and name it .deepl_auth_key')
    def platform_check():
        if sys.platform == "win32":
	        print("C:/Users/USERNAME/.deepl_auth_key")
        elif sys.platform == "darwin":
            print("/Users/USERNAME/.deepl_auth_key")
        elif sys.platform == "linux":
            print("/home/USERNAME/.deepl_auth_key")
        else:
            print("...wherever that is on your system")
    platform_check
    sys.exit(1)
LANGUAGE_OPTIONS={"AR", "BG", "CS", "DA", "DE", "EL", "EN-GB", "EN-US", "ES", "ES-419", "ET", "FI", "FR", "HE", "HU", "ID", "IT", "JA", "KO", "LT", "LV", "NB", "NL", "PL", "PT-BR", "PT-PT", "RO", "RU", "SK", "SL", "SV", "TH", "TR", "UK", "VI", "ZH", "ZH-HAN"}
parser = argparse.ArgumentParser()
parser.add_argument("file", help="text file to translate")
parser.add_argument("language", type=str, help="target language - code like ES or EN-US")
args = parser.parse_args()
if args.language not in LANGUAGE_OPTIONS:
    print(f"Error: '{args.language}' is not a recognized language.")
    print('Recognized languages: AR (Arabic) BG (Bulgarian) CS (Czech) DA (Danish) DE (German) EL (Greek) EN-GB (British English) EN-US (American English) ES (Spanish) ES-419 (LatAm Spanish) ET (Estonian) FI (Finnish) FR (French) HE (Hebrew) HU (Hungarian) ID (Indonesian) IT (Italian) JA (Japanese) KO (Korean) LT (Lithuanian) LV (Latvian) NB (Norwegian) NL (Dutch) PL (Polish) PT-BR (Brazilian Portuguese) PT-PT (European Portuguese) RO (Romanian) RU (Russian) SK (Slovak) SL (Slovenian) SV (Swedish) TH (Thai) TR (Turkish) UK (Ukrainian) VI (Vietnamese) ZH (Simplified Chinese) ZH-HANS (Simplified Chinese) ZH-HANT (Traditional Chinese)')
    sys.exit(1)
else:
    language = args.language
text_file = (args.file)
with open(text_file, 'r') as file:
    contents = file.read()
#make sure the authkey is passed as a string and not an object
auth_key = str(deepl_auth_key)
translator = deepl.Translator(auth_key)
lang = str(language)
result = translator.translate_text(contents, target_lang="%s" % language)
print(result.text)
deepl_client = deepl.DeepLClient(auth_key)
usage = deepl_client.get_usage()
if usage.any_limit_reached:
    print('\033[31;1m', end='')
    print('Translation limit reached.')
    print('\x1b[0m', end='')
if usage.character.valid:
    print('\033[34;1m', end='')
    print(f"Character usage: {usage.character.count} of {usage.character.limit}")
    print('\x1b[0m', end='')
