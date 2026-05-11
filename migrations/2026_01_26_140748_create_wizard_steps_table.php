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
        Schema::create('wizard_steps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_type_id')->constrained()->onDelete('cascade');
            $table->integer('step_number');
            $table->string('identifier')->unique();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('component_name');
            $table->boolean('is_required')->default(true);
            $table->boolean('can_skip')->default(false);
            $table->json('data_requirements')->nullable();
            $table->json('validation_rules')->nullable();
            $table->json('navigation_config')->nullable();
            $table->json('conditional_logic')->nullable();
            $table->json('metadata')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->unique(['listing_type_id', 'step_number']);
            $table->index(['listing_type_id', 'is_active', 'step_number']);
            $table->index('identifier');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('wizard_steps');
    }
};
