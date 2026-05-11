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
        Schema::create('purpose_types', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Business, Medical, Student, Vacation, Family, Relocation, Event
            $table->string('slug')->unique();
            $table->string('icon')->nullable(); // Material icon name
            $table->text('description')->nullable();
            $table->string('color')->default('#6366f1'); // For UI badges
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Seed default purpose types
        DB::table('purpose_types')->insert([
            ['name' => 'Vacation', 'slug' => 'vacation', 'icon' => 'beach_access', 'description' => 'Leisure and holiday stays', 'color' => '#10b981', 'sort_order' => 1, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Business', 'slug' => 'business', 'icon' => 'business_center', 'description' => 'Work and corporate travel', 'color' => '#3b82f6', 'sort_order' => 2, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Medical', 'slug' => 'medical', 'icon' => 'local_hospital', 'description' => 'Near hospitals and clinics', 'color' => '#ef4444', 'sort_order' => 3, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Student', 'slug' => 'student', 'icon' => 'school', 'description' => 'Near universities and colleges', 'color' => '#f59e0b', 'sort_order' => 4, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Family', 'slug' => 'family', 'icon' => 'family_restroom', 'description' => 'Family-friendly accommodations', 'color' => '#8b5cf6', 'sort_order' => 5, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Relocation', 'slug' => 'relocation', 'icon' => 'home_work', 'description' => 'Long-term stays for moving', 'color' => '#06b6d4', 'sort_order' => 6, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Event', 'slug' => 'event', 'icon' => 'celebration', 'description' => 'Weddings, conferences, gatherings', 'color' => '#ec4899', 'sort_order' => 7, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Safari & Adventure', 'slug' => 'safari', 'icon' => 'landscape', 'description' => 'Near parks and reserves', 'color' => '#84cc16', 'sort_order' => 8, 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('purpose_types');
    }
};
