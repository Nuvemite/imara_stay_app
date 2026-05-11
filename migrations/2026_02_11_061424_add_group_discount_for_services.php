<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add group discount for services (listing_type_id = 3)
        DB::table('promotion_types')->insert([
            'name' => 'Group discount',
            'slug' => 'group-discount-service',
            'description' => 'Save when booking for multiple guests',
            'type' => 'percentage',
            'default_value' => 10,
            'min_nights' => 4, // minimum guests required
            'listing_type_id' => 3, // Services
            'is_active' => 1,
            'icon' => 'groups',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('promotion_types')
            ->where('slug', 'group-discount-service')
            ->where('listing_type_id', 3)
            ->delete();
    }
};
