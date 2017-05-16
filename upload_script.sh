FILENAME="installer-`date +'%Y%m%d-%H%M%S'`.dmg"
rm -f script_installer/$FILENAME
appdmg script_installer/info.json script_installer/$FILENAME
gsutil cp script_installer/$FILENAME gs://focusplan-74d7e.appspot.com/
gsutil acl ch -u AllUsers:R gs://focusplan-74d7e.appspot.com/$FILENAME

echo "https://storage.googleapis.com/focusplan-74d7e.appspot.com/$FILENAME"