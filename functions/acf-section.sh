source /home/serii/Documents/bash-wp/functions/acf-functions.sh

function selectPage(){
  local pages_json=$(wp post list --post_type=page --format=json)
  local pages=($(echo $pages_json | jq -r '.[] | .post_title'))
  local pages_slug=($(echo $pages_json | jq -r '.[] | .post_name'))
  local pages_ids=($(echo $pages_json | jq -r '.[] | .ID'))
  select page in "${pages_slug[@]}"; do
    [[ $page ]] || continue
    local page_id=$(echo $pages_json | jq -r '.[] | select(.post_name == "'${page}'") | .ID')
    echo "{
    \"param\": \"page\",
    \"operator\": \"==\",
    \"value\": \"${page_id}\"
    }"
  break
done
}

function chooseType(){
  select type in "page" "post_type" "taxonomy"; do
    [[ $type ]] || continue
    case $type in
      "page")
        selectPage
        break
        ;;
      "post_type")
        echo "some"
        break
        ;;
    esac
    break
  done
}

function newSection(){
  local setting=$(chooseType)

  local id="$(openssl rand -base64 12)"
  local tab_id="$(openssl rand -base64 12)"
  local group_id="$(openssl rand -base64 12)"
  read -p "Enter the name of the section: " section_input
  local slug=$(echo $section_input | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  cat <<TEST >> "acf/$slug.json"
[
    {
        "ID": false,
        "key": "group_${id}",
        "title": "${section_input}",
        "fields": [
            {
                "key": "field_${tab_id}",
                "label": "Test",
                "name": "",
                "aria-label": "",
                "type": "tab",
                "instructions": "",
                "required": 0,
                "conditional_logic": 0,
                "wrapper": {
                    "width": "",
                    "class": "",
                    "id": ""
                  },
                "placement": "top",
                "endpoint": 0
              },
            {
                "key": "field_${group_id}",
                "label": "Test",
                "name": "test",
                "aria-label": "",
                "type": "group",
                "instructions": "",
                "required": 0,
                "conditional_logic": 0,
                "wrapper": {
                    "width": "",
                    "class": "",
                    "id": ""
                  },
                "layout": "block",
                "sub_fields": []
              }
        ],
        "location": [
            [
                ${setting}
            ]
        ],
        "menu_order": 0,
        "position": "normal",
        "style": "default",
        "label_placement": "top",
        "instruction_placement": "label",
        "hide_on_screen": "",
        "active": true,
        "description": "",
        "show_in_rest": 0,
        "_valid": true
      }
]
TEST
wpImport
}
