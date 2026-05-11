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
        Schema::create('experiences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('host_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('category_id')->constrained('categories')->cascadeOnDelete();
            
            // Basics
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description'); // The "Story"
            $table->string('language')->default('English');
            
            // Location - Matching Listings table structure for consistency
            $table->string('location'); // General location name
            $table->string('address_line_1')->nullable();
            $table->string('city')->nullable();
            $table->string('country')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();

            // Details
            $table->integer('duration_minutes'); // e.g., 120 for 2 hours
            $table->integer('max_guests');
            $table->integer('min_age')->nullable();
            
            // Pricing
            $table->decimal('price_per_person', 10, 2);
            $table->string('currency')->default('USD');
            
            // Status & Quality
            $table->boolean('is_active')->default(true);
            $table->string('status')->default('draft'); // draft, pending, published
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('experiences');
    }
};
