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
        // Insert default configurations for weekend premium limits
        DB::table('system_configurations')->insert([
            [
                'key' => 'weekend_premium_min_percentage',
                'value' => '0',
                'description' => 'Minimum percentage for weekend premium',
                'type' => 'number',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'weekend_premium_max_percentage',
                'value' => '99',
                'description' => 'Maximum percentage for weekend premium',
                'type' => 'number',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'weekend_premium_default_percentage',
                'value' => '1',
                'description' => 'Default percentage for weekend premium',
                'type' => 'number',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('system_configurations')
            ->whereIn('key', [
                'weekend_premium_min_percentage',
                'weekend_premium_max_percentage',
                'weekend_premium_default_percentage'
            ])
            ->delete();
    }
};
