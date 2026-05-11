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
            // Update existing NULL property_type_id to a default value first
            $table->unsignedBigInteger('property_type_id')->default(1)->nullable(false)->change();
        });

        Schema::table('listings', function (Blueprint $table) {
            // Add foreign key for property_type_id if it doesn't exist
            try {
                $table->foreign('property_type_id')->references('id')->on('property_types')->restrictOnDelete();
            } catch (\Exception $e) {
                // Constraint likely exists
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            // Make property_type_id nullable again
            $table->unsignedBigInteger('property_type_id')->nullable()->change();
        });
    }
};
