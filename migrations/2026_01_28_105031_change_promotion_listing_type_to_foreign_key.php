<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add the new foreign key column if it doesn't exist
        Schema::table('promotion_types', function (Blueprint $table) {
            if (! Schema::hasColumn('promotion_types', 'listing_type_id')) {
                $table->unsignedBigInteger('listing_type_id')->nullable()->after('type');
                $table->foreign('listing_type_id')->references('id')->on('listing_types')->onDelete('cascade');
            }
        });

        // Update existing data before dropping the old column (only if old column exists)
        if (Schema::hasColumn('promotion_types', 'listing_type')) {
            DB::statement("
                UPDATE promotion_types SET listing_type_id = 
                    CASE 
                        WHEN listing_type = 'home' THEN 1
                        WHEN listing_type = 'experience' THEN 2
                        WHEN listing_type = 'both' THEN NULL
                        ELSE NULL
                    END
            ");

            // Now drop the old enum column
            Schema::table('promotion_types', function (Blueprint $table) {
                $table->dropColumn('listing_type');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop foreign key and column
        Schema::table('promotion_types', function (Blueprint $table) {
            $table->dropForeign(['listing_type_id']);
            $table->dropColumn('listing_type_id');
        });

        // Add back the enum column
        Schema::table('promotion_types', function (Blueprint $table) {
            $table->enum('listing_type', ['home', 'experience', 'both'])->default('both')->after('type');
        });

        // Restore data (approximate)
        DB::statement("
            UPDATE promotion_types SET listing_type = 'both' WHERE listing_type_id IS NULL
        ");
    }
};
