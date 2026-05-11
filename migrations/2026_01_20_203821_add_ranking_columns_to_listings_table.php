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
            $table->integer('trust_score')->default(0)->index();
            $table->integer('quality_score')->default(0)->index();
            $table->integer('ranking_score')->default(0)->index(); // Final sort order
            $table->enum('trust_level', ['new', 'verified', 'secure', 'premium', 'elite'])->default('new')->index();
            
            $table->boolean('is_soft_hidden')->default(false);
            $table->string('soft_hide_reason')->nullable();
            
            $table->integer('click_count')->default(0);
            $table->integer('impression_count')->default(0);
            $table->decimal('conversion_rate', 5, 2)->default(0);
            
            $table->boolean('is_instant_bookable')->default(false);
            $table->timestamp('last_calendar_update')->nullable();
            
            $table->json('ranking_metadata')->nullable(); // Explains why it ranked high
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropColumn([
                'trust_score', 
                'quality_score', 
                'ranking_score', 
                'trust_level',
                'is_soft_hidden',
                'soft_hide_reason',
                'click_count',
                'impression_count',
                'conversion_rate',
                'is_instant_bookable',
                'last_calendar_update',
                'ranking_metadata'
            ]);
        });
    }
};
