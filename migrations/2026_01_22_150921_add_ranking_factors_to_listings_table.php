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
            $table->foreignId('purpose_type_id')->nullable()->constrained('purpose_types')->nullOnDelete();
            
            // Host Metrics
            $table->decimal('host_response_rate', 5, 2)->default(100); // 0-100%
            $table->decimal('host_cancellation_rate', 5, 2)->default(0); // 0-100%
            
            // Quality Metrics
            $table->integer('description_completeness')->default(0); // 0-100
            $table->integer('photo_quality_score')->default(0); // 0-100
            $table->integer('price_competitiveness')->default(50); // 0-100 (50 is neutral, 100 is great value)
            
            // Review Insights
            $table->decimal('review_freshness_score', 5, 2)->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['purpose_type_id']);
            $table->dropColumn([
                'purpose_type_id',
                'host_response_rate',
                'host_cancellation_rate',
                'description_completeness',
                'photo_quality_score',
                'price_competitiveness',
                'review_freshness_score'
            ]);
        });
    }
};
