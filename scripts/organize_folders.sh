#!/bin/bash

# Built With Science - Folder Organization Script
# This script organizes all Built With Science projects into a clean structure

echo "🗂️  Built With Science - Folder Organization Script"
echo "=================================================="
echo ""

# Define paths
PROJECT_ROOT="$HOME/Documents/Built-With-Science-Projects"
NEXTJS_CURRENT="$HOME/Desktop/VIBE/Built-With-Science"
FLUTTER_CURRENT="$HOME/built_with_science_app"
BACKUP_CURRENT="$HOME/Desktop/Built-With-Science-BACKUP-20250828"

echo "📋 Current folder locations:"
echo "   Next.js Web: $NEXTJS_CURRENT"
echo "   Flutter App: $FLUTTER_CURRENT"
echo "   Backup:      $BACKUP_CURRENT"
echo ""
echo "📋 Proposed new structure: $PROJECT_ROOT"
echo ""

read -p "🔄 Do you want to organize folders? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Organization cancelled. Folders remain unchanged."
    exit 0
fi

echo ""
echo "🚀 Creating new folder structure..."

# Create the new structure
mkdir -p "$PROJECT_ROOT"/{1-NextJS-Web-Version,2-Flutter-Mobile-Version,3-Backups,4-APK-Releases/{Current,Archive},5-Documentation/{CSV-Data,Screenshots,Development-Logs}}

if [ $? -eq 0 ]; then
    echo "✅ Folder structure created successfully!"
else
    echo "❌ Failed to create folder structure"
    exit 1
fi

echo ""
echo "📦 Moving projects..."

# Move Next.js project
if [ -d "$NEXTJS_CURRENT" ]; then
    echo "   Moving Next.js Web Version..."
    mv "$NEXTJS_CURRENT" "$PROJECT_ROOT/1-NextJS-Web-Version"
    if [ $? -eq 0 ]; then
        echo "   ✅ Next.js project moved successfully!"
    else
        echo "   ❌ Failed to move Next.js project"
    fi
else
    echo "   ⚠️  Next.js project not found at expected location"
fi

# Move Flutter project
if [ -d "$FLUTTER_CURRENT" ]; then
    echo "   Moving Flutter Mobile Version..."
    mv "$FLUTTER_CURRENT" "$PROJECT_ROOT/2-Flutter-Mobile-Version"
    if [ $? -eq 0 ]; then
        echo "   ✅ Flutter project moved successfully!"
    else
        echo "   ❌ Failed to move Flutter project"
    fi
else
    echo "   ⚠️  Flutter project not found at expected location"
fi

# Move backup
if [ -d "$BACKUP_CURRENT" ]; then
    echo "   Moving backup..."
    mv "$BACKUP_CURRENT" "$PROJECT_ROOT/3-Backups/2025-08-28-Complete"
    if [ $? -eq 0 ]; then
        echo "   ✅ Backup moved successfully!"
    else
        echo "   ❌ Failed to move backup"
    fi
else
    echo "   ⚠️  Backup not found at expected location"
fi

# Move APK files
echo "   Moving APK releases..."
mkdir -p "$PROJECT_ROOT/4-APK-Releases/Current"
find "$HOME/Desktop" -name "BuiltWithScience*.apk" -exec mv {} "$PROJECT_ROOT/4-APK-Releases/Current/" \; 2>/dev/null
echo "   ✅ APK files moved to releases folder!"

echo ""
echo "📁 New folder structure:"
ls -la "$PROJECT_ROOT"

echo ""
echo "🎯 Organization completed!"
echo ""
echo "📋 Updated paths:"
echo "   Next.js Web: $PROJECT_ROOT/1-NextJS-Web-Version"
echo "   Flutter App: $PROJECT_ROOT/2-Flutter-Mobile-Version"
echo "   Backups:     $PROJECT_ROOT/3-Backups"
echo "   APK Releases:$PROJECT_ROOT/4-APK-Releases"
echo ""
echo "⚠️  IMPORTANT: Update your development environment to use the new paths!"
echo "   You may need to update IDE workspace settings and terminal shortcuts."
echo ""
echo "✅ All projects are now organized and ready for future development!"