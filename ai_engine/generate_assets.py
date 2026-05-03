import os
import json

# Changed from "/content/app_assets" to local directory
ASSET_DIR = os.path.join(os.path.dirname(__file__), "app_assets")
os.makedirs(ASSET_DIR, exist_ok=True)

# labels.txt
labels = [
    "plastic",
    "paper_cardboard",
    "glass",
    "metal",
    "organic_food",
    "electronic_waste",
    "medical_waste"
]

with open(os.path.join(ASSET_DIR, "labels.txt"), "w") as f:
    for label in labels:
        f.write(label + "\n")

# waste_info.json
waste_info = {
    "plastic": {
        "display_name": "Plastic",
        "risk": "Low",
        "disposal": "Put in plastic recycling bin if clean and dry.",
        "bin_default": "Blue",
        "examples": ["bottle", "plastic cup", "wrapper", "plastic bag"]
    },
    "paper_cardboard": {
        "display_name": "Paper / Cardboard",
        "risk": "Low",
        "disposal": "Put in paper/cardboard recycling bin if dry and clean.",
        "bin_default": "Yellow",
        "examples": ["paper", "carton", "cardboard box", "newspaper"]
    },
    "glass": {
        "display_name": "Glass",
        "risk": "Medium",
        "disposal": "Put in glass recycling bin carefully. Avoid broken shards by hand.",
        "bin_default": "Green",
        "examples": ["glass bottle", "glass jar", "broken glass"]
    },
    "metal": {
        "display_name": "Metal",
        "risk": "Medium",
        "disposal": "Put in metal/can recycling bin. Sharp edges should be handled carefully.",
        "bin_default": "Blue",
        "examples": ["can", "tin", "foil", "metal container"]
    },
    "organic_food": {
        "display_name": "Organic / Food Waste",
        "risk": "Low",
        "disposal": "Put in wet waste / compost / organic bin.",
        "bin_default": "Brown",
        "examples": ["food scraps", "fruit peel", "vegetable waste"]
    },
    "electronic_waste": {
        "display_name": "Electronic Waste",
        "risk": "High",
        "disposal": "Do not put in regular bins. Dispose at authorized e-waste collection point.",
        "bin_default": "Special Collection",
        "examples": ["phone", "charger", "battery", "cable", "small electronics"]
    },
    "medical_waste": {
        "display_name": "Medical Waste",
        "risk": "High",
        "disposal": "Handle carefully. Dispose using medical or hazardous waste collection rules.",
        "bin_default": "Red / Special Collection",
        "examples": ["mask", "glove", "syringe", "medicine packaging"]
    }
}

with open(os.path.join(ASSET_DIR, "waste_info.json"), "w") as f:
    json.dump(waste_info, f, indent=2)

# class_colors.json
class_colors = {
    "plastic": [255, 87, 34],
    "paper_cardboard": [255, 193, 7],
    "glass": [76, 175, 80],
    "metal": [158, 158, 158],
    "organic_food": [139, 195, 74],
    "electronic_waste": [33, 150, 243],
    "medical_waste": [244, 67, 54]
}

with open(os.path.join(ASSET_DIR, "class_colors.json"), "w") as f:
    json.dump(class_colors, f, indent=2)

print("✅ App asset files created in:", ASSET_DIR)
print(os.listdir(ASSET_DIR))
