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
        if (! Schema::hasTable('service_listing_locations')) {
            Schema::create('service_listing_locations', function (Blueprint $table) {
                $table->id();
                $table->foreignId('listing_id')->constrained()->onDelete('cascade');
                $table->foreignId('service_location_type_id')->constrained()->onDelete('cascade');

                // Location details (stored in listing_address table for physical addresses)
                $table->decimal('latitude', 10, 8)->nullable();
                $table->decimal('longitude', 11, 8)->nullable();
                $table->string('service_area_radius')->nullable(); // e.g., "10km", "25km"
                $table->text('meeting_address')->nullable(); // Specific meeting point

                // Additional details for scalability
                $table->decimal('service_area_radius_km', 8, 3)->nullable(); // Numeric radius in km
                $table->integer('max_travel_time_minutes')->nullable(); // Max travel time
                $table->decimal('travel_fee', 8, 2)->nullable(); // Additional travel fee
                $table->json('service_areas')->nullable(); // Array of specific areas/cities
                $table->json('metadata')->nullable(); // For future extensibility

                $table->timestamps();

                // Ensure each listing can have each location type only once
                $table->unique(['listing_id', 'service_location_type_id'], 'svc_loc_listing_type_unique');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_listing_locations');
    }
};
