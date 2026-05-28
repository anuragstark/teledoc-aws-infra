#!/bin/bash

# WebP Image Conversion Script
# This script converts the heaviest images to WebP format

echo "🖼️  Converting images to WebP format..."

# Array of images to convert (relative to project root)
images=(
    "src/assets/images/banner_img.png"
    "src/assets/images/appointment-booking.jpg"
    "src/assets/images/alka.jpg"
    "src/assets/images/appointment_bg_2.jpg"
    "src/assets/images/testimonial-bg.jpg"
)

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "❌ cwebp not found. Installing via Homebrew..."
    brew install webp
fi

# Convert each image
for img in "${images[@]}"; do
    if [ -f "$img" ]; then
        # Get filename without extension
        filename="${img%.*}"
        
        # Convert to WebP with 85% quality
        cwebp -q 85 "$img" -o "${filename}.webp"
        
        # Show file size comparison
        original_size=$(du -h "$img" | cut -f1)
        webp_size=$(du -h "${filename}.webp" | cut -f1)
        
        echo "✅ Converted: $(basename $img) ($original_size) → $(basename ${filename}.webp) ($webp_size)"
    else
        echo "⚠️  File not found: $img"
    fi
done

echo ""
echo "🎉 Conversion complete! Now update your imports in Home.js"
