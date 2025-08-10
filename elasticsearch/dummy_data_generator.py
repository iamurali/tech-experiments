import os
import uuid
from elasticsearch import Elasticsearch
import random
import json
from datetime import datetime, timedelta
import warnings
from faker import Faker
import faker_commerce

# Suppress SSL warnings
warnings.filterwarnings('ignore', message='.*OpenSSL.*')

fake = Faker()
fake.add_provider(faker_commerce.Provider)

# Initialize Elasticsearch client with modern syntax
es = Elasticsearch(
    # hosts=['http://localhost:9200'], # this is for single node
    hosts=['http://localhost:9999'],
    verify_certs=False,
    ssl_show_warn=False
)


def check_elasticsearch_connection():
    """Check if Elasticsearch is running and accessible"""
    try:
        health = es.cluster.health()
        print(f"✅ Elasticsearch is running. Cluster status: {health['status']}")
        return True
    except Exception as e:
        print(f"❌ Cannot connect to Elasticsearch: {e}")
        print("Make sure Elasticsearch is running with: docker compose -f docker-compose.yml up -d")
        return False

def check_index_exists():
    """Check if the ecommerce_products index exists"""
    try:
        exists = es.indices.exists(index="ecommerce_products")
        if exists:
            print("✅ ecommerce_products index exists")
            return True
        else:
            print("❌ ecommerce_products index does not exist")
            print("Please create the index first using the mapping from README.md")
            return False
    except Exception as e:
        print(f"❌ Error checking index: {e}")
        return False

def generate_product(brands):
    category = fake.ecommerce_category()
    brand = random.choice(brands)

    original_price = round(random.uniform(10, 1000), 2)
    discount = random.uniform(0, 0.5)
    price = round(original_price * (1 - discount), 2)

    return {
        "product_id": fake.uuid4(),
        "title": fake.ecommerce_name(),
        "description": fake.text(max_nb_chars=500),
        "category": category,
        "brand": brand,
        "price": price,
        "original_price": original_price,
        "discount_percentage": round(discount * 100, 1),
        "rating": round(random.uniform(1, 5), 1),
        "review_count": random.randint(0, 1000),
        "availability": random.choice(["in_stock", "out_of_stock", "limited"]),
        "stock_quantity": random.randint(0, 100),
        "tags": [str(x).lower() for x in ([brand, category] + fake.ecommerce_name().split()[:2])],
        "attributes": [
            {"name": "color", "value": fake.color_name()},
            {"name": "size", "value": random.choice(["S", "M", "L", "XL"])},
            {"name": "material", "value": fake.word()},
        ],
        "location": {
            "warehouse": f"WH-{random.randint(1, 10)}",
            "coordinates": {
                "lat": float(fake.latitude()),
                "lon": float(fake.longitude()),
            },
        },
        "created_date": fake.date_between(start_date='-1y', end_date='today'),
        "last_updated": datetime.now(),
        "images": [fake.image_url() for _ in range(random.randint(1, 5))],
        "vendor": {
            "id": fake.uuid4(),
            "name": fake.company(),
            "rating": round(random.uniform(3, 5), 1),
        },
    }

if __name__ == "__main__":
    print("🚀 Starting dummy data generation...")

    # Check Elasticsearch connection
    if not check_elasticsearch_connection():
        exit(1)

    # Check if index exists
    if not check_index_exists():
        exit(1)

    brands = [
        "TechCorp", "StyleHub", "HomeEssentials", "SportsPro", "BookWorld",
        "ToyLand", "BeautyMax", "AutoParts", "HealthFirst", "FoodMart"
    ]
    categories = [
        "Electronics", "Clothing", "Home & Kitchen", "Sports", "Books",
        "Toys", "Beauty", "Automotive", "Health", "Grocery"
    ]

    total = 100000
    print(f"📊 Generating {total:,} products...")
    try:
        for i in range(total):
            product = generate_product(brands)
            es.index(index="ecommerce_products", document=product)
            if i % 1000 == 0:
                print(f"✅ Indexed {i:,} products...")
        print(f"🎉 Successfully indexed {total:,} products!")
        es.indices.refresh(index="ecommerce_products")
        print("🔄 Index refreshed - documents are now searchable")
    except Exception as e:
        print(f"❌ Error during indexing: {e}")
        exit(1)
