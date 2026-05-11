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
        Schema::create('component_registry', function (Blueprint $table) {
            $table->id();
            $table->string('component_name')->unique();
            $table->string('import_path');
            $table->json('props_schema')->nullable();
            $table->string('fallback_component')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('component_name');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('component_registry');
    }
};
