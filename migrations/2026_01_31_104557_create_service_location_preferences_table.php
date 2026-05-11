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
        Schema::create('service_location_preferences', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('icon')->nullable();
            $table->string('color')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();

            // Indexes
            $table->index(['is_active', 'sort_order']);
            $table->index('slug');
        });

        // Insert default service location preferences
        DB::table('service_location_preferences')->insert([
            [
                'name' => 'You travel to guests',
                'slug' => 'travel-to-guests',
                'description' => 'You will travel to the guest\'s location to provide the service',
                'icon' => 'directions_car',
                'color' => '#3B82F6',
                'is_active' => true,
                'sort_order' => 1,
                'metadata' => json_encode([
                    'requires_meeting_address' => false,
                    'requires_service_area' => true,
                    'allows_travel_fee' => true,
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Guests come to you',
                'slug' => 'guests-come-to-host',
                'description' => 'Guests will come to your location to receive the service',
                'icon' => 'home',
                'color' => '#10B981',
                'is_active' => true,
                'sort_order' => 2,
                'metadata' => json_encode([
                    'requires_meeting_address' => true,
                    'requires_service_area' => false,
                    'allows_travel_fee' => false,
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Both locations',
                'slug' => 'both-locations',
                'description' => 'Service can be provided at both your location and guest\'s location',
                'icon' => 'swap_horiz',
                'color' => '#8B5CF6',
                'is_active' => true,
                'sort_order' => 3,
                'metadata' => json_encode([
                    'requires_meeting_address' => true,
                    'requires_service_area' => true,
                    'allows_travel_fee' => true,
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Online/Virtual',
                'slug' => 'online-virtual',
                'description' => 'Service provided online through video call or remote access',
                'icon' => 'videocam',
                'color' => '#F59E0B',
                'is_active' => true,
                'sort_order' => 4,
                'metadata' => json_encode([
                    'requires_meeting_address' => false,
                    'requires_service_area' => false,
                    'allows_travel_fee' => false,
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Neutral location',
                'slug' => 'neutral-location',
                'description' => 'Meet at a mutually agreed neutral location (cafe, park, etc.)',
                'icon' => 'meeting_room',
                'color' => '#EF4444',
                'is_active' => true,
                'sort_order' => 5,
                'metadata' => json_encode([
                    'requires_meeting_address' => false,
                    'requires_service_area' => false,
                    'allows_travel_fee' => false,
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_location_preferences');
    }
};
