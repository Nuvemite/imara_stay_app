<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $appSettingsId = DB::table('system_configuration_types')->where('slug', 'app-settings')->value('id');

        if ($appSettingsId) {
            DB::table('system_configurations')->updateOrInsert(
                ['key' => 'min_listing_price'],
                [
                    'system_configuration_type_id' => $appSettingsId,
                    'value' => '10',
                    'label' => 'Minimum Listing Price',
                    'type' => 'number',
                    'description' => 'The minimum price per night allowed for any listing',
                    'is_required' => 1,
                    'sort_order' => 21,
                    'is_active' => 1,
                    'validation_rules' => json_encode(['required', 'numeric', 'min:0']),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );

            DB::table('system_configurations')->updateOrInsert(
                ['key' => 'max_listing_price'],
                [
                    'system_configuration_type_id' => $appSettingsId,
                    'value' => '10000',
                    'label' => 'Maximum Listing Price',
                    'type' => 'number',
                    'description' => 'The maximum price per night allowed for any listing',
                    'is_required' => 1,
                    'sort_order' => 22,
                    'is_active' => 1,
                    'validation_rules' => json_encode(['required', 'numeric', 'min:0']),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('system_configurations')->whereIn('key', ['min_listing_price', 'max_listing_price'])->delete();
    }
};
