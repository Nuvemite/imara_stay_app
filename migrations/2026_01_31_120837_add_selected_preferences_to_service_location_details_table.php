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
        Schema::table('service_location_details', function (Blueprint $table) {
            // Add selected_preferences column if it doesn't exist
            if (! Schema::hasColumn('service_location_details', 'selected_preferences')) {
                $table->json('selected_preferences')->nullable()->after('listing_id');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('service_location_details', function (Blueprint $table) {
            $table->dropColumn('selected_preferences');
        });
    }
};
