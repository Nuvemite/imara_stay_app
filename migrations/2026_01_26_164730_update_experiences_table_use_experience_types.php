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
        Schema::table('experiences', function (Blueprint $table) {
            // Drop foreign key for category_id
            $table->dropForeign(['category_id']);
            
            // Drop category_id column
            $table->dropColumn('category_id');
            
            // Add experience_type_id column
            $table->foreignId('experience_type_id')->nullable()->constrained('experience_types')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('experiences', function (Blueprint $table) {
            // Drop experience_type_id
            $table->dropForeign(['experience_type_id']);
            $table->dropColumn('experience_type_id');
            
            // Re-add category_id
            $table->foreignId('category_id')->constrained('categories')->cascadeOnDelete();
        });
    }
};
