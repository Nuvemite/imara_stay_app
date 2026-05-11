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
            // About You
            $table->integer('host_years_experience')->default(0);
            $table->text('host_intro')->nullable();
            $table->text('host_expertise')->nullable();
            $table->json('social_profiles')->nullable(); // Array of { provider, url }

            // Experience Details
            $table->decimal('duration_hours', 5, 2)->default(2.0); // e.g. 2.5 hours
            $table->json('languages')->nullable();
            $table->integer('min_age')->default(18);
            $table->text('inclusions')->nullable();
            $table->text('exclusions')->nullable();

            // Itinerary
            $table->json('itinerary')->nullable(); // Array of steps

            // Pricing Extended
            $table->decimal('private_group_price', 10, 2)->nullable();
            // discounts handled via existing promotions or new pivot if complex, using json for now for simplicity if lightweight
            
            // Transport / Details
            $table->boolean('transportation_provided')->default(false);
            $table->json('transportation_methods')->nullable();
            $table->boolean('terms_accepted')->default(false);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropColumn([
                'host_years_experience',
                'host_intro',
                'host_expertise',
                'social_profiles',
                'duration_hours',
                'languages',
                'min_age',
                'inclusions',
                'exclusions',
                'itinerary',
                'private_group_price',
                'transportation_provided',
                'transportation_methods',
                'terms_accepted'
            ]);
        });
    }
};
