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
        Schema::table('listings', function (Blueprint $table) {
            $table->boolean('service_travel_to_guests')->default(false);
            $table->boolean('service_guests_travel_to_host')->default(false);
            $table->text('service_meeting_address')->nullable();
            $table->string('service_area_radius')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropColumn(['service_travel_to_guests', 'service_guests_travel_to_host', 'service_meeting_address', 'service_area_radius']);
        });
    }
};
