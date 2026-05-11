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
        // Experience Levels
        if (!Schema::hasTable('experience_levels')) {
            Schema::create('experience_levels', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Beginner', 'Intermediate', 'Advanced', 'Expert'
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('icon')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Cancellation Policy Types
        if (!Schema::hasTable('cancellation_policy_types')) {
            Schema::create('cancellation_policy_types', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Flexible', 'Moderate', 'Strict'
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->integer('hours_before_cancellation')->default(24);
                $table->decimal('refund_percentage', 5, 2)->default(100.00);
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Offering Types
        if (!Schema::hasTable('offering_types')) {
            Schema::create('offering_types', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Standard', 'Premium', 'Package', 'Custom'
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Price Units
        if (!Schema::hasTable('price_units')) {
            Schema::create('price_units', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Fixed', 'Per Person', 'Per Hour', 'Per Session'
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Transportation Methods
        if (!Schema::hasTable('transportation_methods')) {
            Schema::create('transportation_methods', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Car', 'Boat', 'Plane', 'Motorcycle', 'Bicycle', 'Walking'
                $table->string('slug')->unique();
                $table->string('icon')->nullable();
                $table->text('description')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Qualification Types
        if (!Schema::hasTable('qualification_types')) {
            Schema::create('qualification_types', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Certification', 'License', 'Degree', 'Training', 'Experience', 'Award'
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('icon')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Skill Levels
        if (!Schema::hasTable('skill_levels')) {
            Schema::create('skill_levels', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Basic', 'Intermediate', 'Advanced', 'Expert'
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('sort_order')->default(0);
                $table->timestamps();
            });
        }

        // Days of Week
        if (!Schema::hasTable('days_of_week')) {
            Schema::create('days_of_week', function (Blueprint $table) {
                $table->id();
                $table->string('name'); // 'Monday', 'Tuesday', etc.
                $table->string('short_name'); // 'Mon', 'Tue', etc.
                $table->string('slug')->unique(); // 'monday', 'tuesday', etc.
                $table->integer('day_number'); // 1-7 (Monday=1)
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('days_of_week');
        Schema::dropIfExists('skill_levels');
        Schema::dropIfExists('qualification_types');
        Schema::dropIfExists('transportation_methods');
        Schema::dropIfExists('price_units');
        Schema::dropIfExists('offering_types');
        Schema::dropIfExists('cancellation_policy_types');
        Schema::dropIfExists('experience_levels');
    }
};
