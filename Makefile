script:
	$name = installer-`date +'%Y%m%d-%H%M%S'`.dmg
	rm -f script_installer/$name
	appdmg script_installer/info.json script_installer/$name
	gsutil cp script_installer/$name gs://focusplan-74d7e.appspot.com/
	gsutil acl ch -u AllUsers:R gs://focusplan-74d7e.appspot.com/$name