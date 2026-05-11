<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Add Discount Limits to System Configurations
        DB::table('system_configurations')->insert([
            [
                'name' => 'Min Discount Percentage',
                'key' => 'min_discount_percentage',
                'value' => '0',
                'group' => 'app-settings',
                'type' => 'number',
                'is_public' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Max Discount Percentage',
                'key' => 'max_discount_percentage',
                'value' => '30',
                'group' => 'app-settings',
                'type' => 'number',
                'is_public' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);

        // 2. Modify promotion_types enum to include 'fixed_price'
        DB::statement("ALTER TABLE promotion_types MODIFY COLUMN type ENUM('percentage', 'fixed', 'fixed_price') NOT NULL DEFAULT 'percentage'");

        // 3. Add Custom Length-of-Stay Price Promotion Type
        DB::table('promotion_types')->insert([
            'name' => 'Custom Duration Price',
            'slug' => 'custom-duration-price', // Distinct slug
            'description' => 'Set a fixed total price for a specific number of nights',
            'icon' => 'payments', // Google Material Icon
            'default_value' => 0,
            'min_nights' => null, // User defined
            'type' => 'fixed_price',
            'listing_type_id' => null, // Available for all? Or just homes? Let's say null (all)
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // 1. Remove System Configs
        DB::table('system_configurations')
            ->whereIn('key', ['min_discount_percentage', 'max_discount_percentage'])
            ->delete();

        // 2. Remove Custom Promotion Type
        DB::table('promotion_types')
            ->where('slug', 'custom-duration-price')
            ->delete();

        // 3. Revert Enum (Warning: this might fail if data exists with 'fixed_price', but in down() we just deleted the known one)
        // We will try to revert, but if other data exists, it might be safer to leave it or cascade.
        // For this specific task, we only added one row.
        DB::statement("ALTER TABLE promotion_types MODIFY COLUMN type ENUM('percentage', 'fixed') NOT NULL DEFAULT 'percentage'");
    }
};
