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
        Schema::dropIfExists('wizard_steps');
        Schema::dropIfExists('wizard_step_dependencies');
        Schema::dropIfExists('wizard_step_validations');
        Schema::dropIfExists('wizard_step_conditions');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Recreate tables if needed (reverse of up)
    }
};
