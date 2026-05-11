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
        Schema::create('service_location_types', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g., "You travel to guests", "Guests come to you", "Both"
            $table->string('slug')->unique(); // e.g., "travel-to-guests", "guests-come-to-host", "both"
            $table->text('description')->nullable();
            $table->string('icon')->nullable(); // Material icon name
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->json('metadata')->nullable(); // For future extensibility
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_location_types');
    }
};
