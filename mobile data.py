from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import csv
import time
import re

brands = {
    "Samsung": "https://www.smartprix.com/mobiles/samsung-brand",
    "Oppo": "https://www.smartprix.com/mobiles/oppo-brand",
    "Vivo": "https://www.smartprix.com/mobiles/vivo-brand",
    "Moto": "https://www.smartprix.com/mobiles/motorola-brand",
    "OnePlus": "https://www.smartprix.com/mobiles/oneplus-brand",
    "Xiaomi": "https://www.smartprix.com/mobiles/xiaomi-brand",
    "Realme": "https://www.smartprix.com/mobiles/realme-brand"
}

def clean_spec(text, pattern):
    match = re.search(pattern, text)
    return match.group(0) if match else "N/A"

def scrape_smartprix_detailed():
    options = Options()
    options.add_argument("--disable-blink-features=AutomationControlled")
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    all_data = []

    try:
        for brand, url in brands.items():
            print(f"Scraping {brand}...")
            driver.get(url)
            time.sleep(5) # Give it time to load

            # Find all products
            items = driver.find_elements(By.CLASS_NAME, "sm-product")

            for item in items[:15]: # Taking top 15 per brand
                try:
                    name = item.find_element(By.TAG_NAME, "h2").text
                    price = item.find_element(By.CLASS_NAME, "price").text.replace("₹", "").strip()
                    
                    # Rating/Spec Score
                    try:
                        spec_score = item.find_element(By.CLASS_NAME, "score").text
                    except:
                        spec_score = "N/A"

                    # Get all text from the features list
                    full_specs = item.find_element(By.CLASS_NAME, "sm-feat").text
                    
                    # Use Regex to separate the data into your specific columns
                    ram_storage = clean_spec(full_specs, r"\d+\s*GB\s*RAM.*")
                    camera = clean_spec(full_specs, r"\d+\s*MP.*Camera")
                    battery = clean_spec(full_specs, r"\d+\s*mAh.*")
                    processor = clean_spec(full_specs, r".*Processor")

                    all_data.append({
                        "Brand Name": brand,
                        "Model Name": name,
                        "Launch Year": "2026",
                        "Price (₹)": price,
                        "RAM, Storage": ram_storage,
                        "Camera (MP)": camera,
                        "Battery (mAh)": battery,
                        "Processor": processor,
                        "SPECS SCORE": spec_score,
                        "Rating": "N/A" # Smartprix uses Score as their primary rating
                    })
                except Exception:
                    continue
            print(f"Success for {brand}")

    finally:
        driver.quit()

    # Save to CSV
    if all_data:
        keys = all_data[0].keys()
        with open('final_samsung_project_data.csv', 'w', newline='', encoding='utf-8') as f:
            dict_writer = csv.DictWriter(f, fieldnames=keys)
            dict_writer.writeheader()
            dict_writer.writerows(all_data)
        print("\nSUCCESS: 'final_samsung_project_data.csv' is ready on your computer.")

if __name__ == "__main__":
    scrape_smartprix_detailed()