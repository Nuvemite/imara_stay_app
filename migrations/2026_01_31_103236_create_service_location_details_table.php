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
        Schema::create('service_location_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_id')->constrained()->onDelete('cascade');

            // Service location preferences (configurable)
            $table->json('selected_preferences')->nullable(); // Array of preference IDs

            // Meeting address details
            $table->string('meeting_address_line_1')->nullable();
            $table->string('meeting_address_line_2')->nullable();
            $table->string('meeting_building_name')->nullable();
            $table->string('meeting_unit_number')->nullable();
            $table->string('meeting_city')->nullable();
            $table->string('meeting_state')->nullable();
            $table->string('meeting_postal_code')->nullable();
            $table->string('meeting_country')->nullable();
            $table->string('meeting_country_code')->nullable();
            $table->decimal('meeting_latitude', 10, 8)->nullable();
            $table->decimal('meeting_longitude', 11, 8)->nullable();

            // Service area
            $table->decimal('service_area_radius_km', 8, 2)->nullable();
            $table->string('service_area_radius')->nullable(); // For backward compatibility

            // Travel details
            $table->integer('max_travel_time_minutes')->nullable();
            $table->decimal('travel_fee', 8, 2)->nullable();

            // Service areas (JSON for multiple areas)
            $table->json('service_areas')->nullable();

            // Metadata
            $table->json('metadata')->nullable();

            $table->timestamps();

            // Indexes
            $table->index('listing_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_location_details');
    }
};
