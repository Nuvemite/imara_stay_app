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
        // Pricing Models
        Schema::create('pricing_models', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // 'Fixed Price', 'Per Person', 'Per Hour', 'Custom'
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Availability Types
        Schema::create('availability_types', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // 'Custom Hours', 'Always Available', 'By Appointment'
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Experience Levels
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

        // Cancellation Policy Types
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

        // Offering Types
        Schema::create('offering_types', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // 'Standard', 'Premium', 'Package', 'Custom'
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Price Units
        Schema::create('price_units', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // 'Fixed', 'Per Person', 'Per Hour', 'Per Session'
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Transportation Methods
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

        // Qualification Types
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

        // Skill Levels
        Schema::create('skill_levels', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // 'Basic', 'Intermediate', 'Advanced', 'Expert'
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Days of Week
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
        Schema::dropIfExists('availability_types');
        Schema::dropIfExists('pricing_models');
    }
};
