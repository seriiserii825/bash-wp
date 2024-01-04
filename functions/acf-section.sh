source /home/serii/Documents/bash-wp/functions/acf-functions.sh

function newSection(){
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
                {
                    "param": "post_type",
                    "operator": "==",
                    "value": "post"
                }
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
