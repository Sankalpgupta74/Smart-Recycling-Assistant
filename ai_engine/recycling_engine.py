import pandas as pd
from googletrans import Translator

# Initialize the Global Translator for Multilingual Support
translator = Translator()

def load_recycling_db(csv_path):
    """
    Loads the Global Bin Color CSV database.
    """
    try:
        df = pd.read_csv(csv_path)
        print(f"✅ Database loaded successfully from: {csv_path}")
        return df
    except Exception as e:
        print(f"❌ Error loading CSV: {e}")
        return None

def get_global_guidance(material, country, df_bins):
    """
    The Core Engine: 
    1. Identifies Hira Rules (Action/Safety)
    2. Cross-references CSV for Bin Colors & Language
    3. Translates output to the local language
    """
    
    # 1. Base Hira Knowledge Base (Internal Logic)
    base_info = {
        'glass': {
            'lifecycle': 'REUSABLE / RECYCLABLE', 
            'action': 'Wash and reuse as a storage jar or decorative item.', 
            'safety': '🐾 ANIMAL SAFETY: Wrap in thick paper/cardboard to prevent injuries to street animals.'
        },
        'plastic': {
            'lifecycle': 'RECYCLABLE', 
            'action': 'Check for recycling symbol. Remove caps and crush the bottle.', 
            'safety': '⚠️ LIQUID WARNING: Ensure container is 100% EMPTY before disposal.'
        },
        'metal': {
            'lifecycle': 'RECYCLABLE', 
            'action': 'Rinse food residue. Flatten cans to save space.', 
            'safety': '🚨 SHARP EDGES: Metal edges are dangerous. Handle with care.'
        },
        'organic': {
            'lifecycle': 'DISPOSABLE / COMPOSTABLE', 
            'action': 'Perfect for home composting or natural decay.', 
            'safety': '🍎 NATURAL: Safe for animals like cows/dogs if clean.'
        },
        'paper': {
            'lifecycle': 'RECYCLABLE', 
            'action': 'Keep dry. Do not recycle if oily (like pizza boxes).', 
            'safety': 'Standard disposal.'
        },
        'cardboard': {
            'lifecycle': 'RECYCLABLE', 
            'action': 'Flatten boxes. Remove plastic tape.', 
            'safety': 'Standard disposal.'
        },
        'trash': {
            'lifecycle': 'NON-REUSABLE / TRASH', 
            'action': 'General disposal. Try to avoid using this material.', 
            'safety': 'Standard disposal.'
        }
    }
    
    # 2. Extract Data from CSV (Location Awareness)
    # Search for the country row in the dataframe
    country_row = df_bins[df_bins['Country'].str.lower() == country.lower()]
    
    if not country_row.empty:
        # Get the language code (e.g., 'hi' for Hindi, 'ja' for Japanese)
        lang_code = country_row['Language_Code'].values[0] 
        # Match material name to the specific column in your CSV
        bin_color = country_row[material.capitalize()].values[0]
    else:
        # Fallback to English if country is not in database
        lang_code = 'en'
        bin_color = "Standard Waste Bin"

    # Get the English version of instructions from Hira Logic
    info = base_info.get(material.lower(), base_info['trash'])

    # 3. Multilingual Translation Step
    try:
        # Translate the Action, Safety, and Lifecycle strings
        trans_action = translator.translate(info['action'], dest=lang_code).text
        trans_safety = translator.translate(info['safety'], dest=lang_code).text
        trans_lifecycle = translator.translate(info['lifecycle'], dest=lang_code).text
        
        # We keep Bin Color as is from CSV, or you can translate that too:
        trans_bin = f"{bin_color} Bin"
    except Exception as e:
        # If translation fails (no internet), we use English as a safety net
        print(f"⚠️ Translation service busy. Using English fallback.")
        trans_action, trans_safety, trans_lifecycle = info['action'], info['safety'], info['lifecycle']
        trans_bin = f"{bin_color} Bin"

    # Return the final consolidated dictionary
    return {
        'country': country,
        'language': lang_code,
        'material': material.upper(),
        'lifecycle': trans_lifecycle,
        'action': trans_action,
        'safety': trans_safety,
        'bin': trans_bin.upper()
    }