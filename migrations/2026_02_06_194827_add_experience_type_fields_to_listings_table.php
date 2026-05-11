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
            // Add experience_type_id column for experiences (similar to service_type_id)
            $table->foreignId('experience_type_id')->nullable()
                ->after('service_type_id')
                ->constrained('experience_types')
                ->nullOnDelete();
            
            // Add experience_subcategory_id column
            $table->foreignId('experience_subcategory_id')->nullable()
                ->after('experience_type_id')
                ->constrained('experience_subcategories')
                ->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['experience_type_id']);
            $table->dropForeign(['experience_subcategory_id']);
            $table->dropColumn(['experience_type_id', 'experience_subcategory_id']);
        });
    }
};
