# Wrapper for whiptail/dialog/bash-console to display the interface on console

WHIPTAIL () {
    height=20
    width=78
    dtype=error
    scrolltext=""
    title=""
    CHOICES=()
    backtitle="Plone Unified Installer"
    for option; do
        optarg=`expr "x$option" : 'x[^=]*=\(.*\)'`
        case $option in
            --height=*)
                height=$optarg
                ;;
            --width=*)
                width=$optarg
                ;;
            --yesno | --msgbox | --inputbox | --passwordbox | --menu )
                dtype=$option
                ;;
            --title=* )
                title="$optarg"
                ;;
            --scrolltext )
                scrolltext=$option
                ;;
            --choices=*)
                OIFS="$IFS"
                IFS="#"
                CHOICES=($optarg)
                IFS="$OIFS"
                ;;
            --backtitle=*)
                backtitle="$optarg"
                ;;
            *)
                prompt="$option"
                ;;
        esac
    done


    if [ "X$whipdialog" == "X" ]; then
        whipdialog=`which dialog || which whiptail`
    	if [ $? -gt 0 ]; then
    	    whipdialog="bashme"
    	fi
    fi
    if [ "X$whipdialog" == "Xdialog" ]; then
        scrolltext=""
    fi

    if [ $whipdialog == "bashme" ]; then
        clear
        echo "=========================================="
        echo $backtitle
        echo "------------------------------------------"
        echo "$title"
        echo "=========================================="
        case "$dtype" in
            --yesno)
                echo "$prompt"
                echo
                select answer in "Yes" "No"; do
                    case $answer in
                        "Yes")
                            [ 0 -eq 0 ]
                            return "$?"
                            ;;
                        "No")
                            [ 1 -eq 0 ]
                            return "$?"
                            ;;
                    esac
                done
                ;;
            --menu)
                echo $prompt
                select answer in "${CHOICES[@]}"; do
                    WHIPTAIL_RESULT="$answer"
                    break
                done
                ;;
            --msgbox)
                echo "$prompt"
                echo
                read -p "Press any key: " -n 1
                echo
                ;;
            --inputbox)
                read -e -p "$prompt" WHIPTAIL_RESULT
                ;;
            --passwordbox)
                read -e -s -p "$prompt" WHIPTAIL_RESULT
                ;;
            *)
                echo "Unknown dialog type"
                exit 1
        esac
    else
        if [ "$dtype" == "--menu" ]; then
            # double the choices
            DCHOICES=()
            for item in "${CHOICES[@]}"; do
                DCHOICES=("${DCHOICES[@]}" "$item" "")
            done
            WHIPTAIL_RESULT=$($whipdialog --title "$title" --backtitle "$backtitle" \
                $dtype "$prompt" $height $width \
                ${#CHOICES[@]} "${DCHOICES[@]}" 3>&1 1>&2 2>&3)
        else
            WHIPTAIL_RESULT=$($whipdialog --title "$title" --backtitle "$backtitle" \
                $dtype "$prompt" $height $width \
                3>&1 1>&2 2>&3)
        fi
    fi
    return $?
}
