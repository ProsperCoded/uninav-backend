CREATE TYPE "public"."advert_type" AS ENUM('free', 'pro', 'boost', 'targeted');--> statement-breakpoint
CREATE TYPE "public"."approval_status" AS ENUM('pending', 'approved', 'rejected');--> statement-breakpoint
CREATE TYPE "public"."blog_type" AS ENUM('article', 'guideline', 'scheme_of_work', 'tutorial');--> statement-breakpoint
CREATE TYPE "public"."material_type" AS ENUM('pdf', 'video', 'article', 'image', 'other');--> statement-breakpoint
CREATE TYPE "public"."resource_type" AS ENUM('url', 'GDrive', 'upload');--> statement-breakpoint
CREATE TYPE "public"."restriction_enum" AS ENUM('readonly', 'downloadable');--> statement-breakpoint
CREATE TYPE "public"."user_id_type" AS ENUM('id_card', 'admission_letter');--> statement-breakpoint
CREATE TYPE "public"."user_role" AS ENUM('student', 'moderator', 'admin');--> statement-breakpoint
CREATE TYPE "public"."visibility_enum" AS ENUM('public', 'private');--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" text NOT NULL,
	"firstName" text NOT NULL,
	"lastName" text NOT NULL,
	"username" text NOT NULL,
	"department" uuid,
	"level" integer NOT NULL,
	"role" "user_role" DEFAULT 'student',
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email"),
	CONSTRAINT "users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
CREATE TABLE "auth" (
	"user_id" uuid PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false,
	"password" text NOT NULL,
	"matric_no" text,
	"user_id_type" "user_id_type",
	"user_id_image" text,
	"user_id_verified" boolean DEFAULT false,
	CONSTRAINT "auth_email_unique" UNIQUE("email"),
	CONSTRAINT "auth_matric_no_unique" UNIQUE("matric_no")
);
--> statement-breakpoint
CREATE TABLE "moderator" (
	"userId" uuid PRIMARY KEY NOT NULL,
	"department" uuid,
	"faculty" uuid,
	"review_status" "approval_status" DEFAULT 'pending'
);
--> statement-breakpoint
CREATE TABLE "faculty" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"description" text,
	CONSTRAINT "faculty_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "department" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"facultyId" uuid,
	CONSTRAINT "department_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "courses" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"courseName" text NOT NULL,
	"courseCode" text NOT NULL,
	"description" text NOT NULL,
	"review_status" "approval_status" DEFAULT 'pending',
	"reviewedBy" uuid,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "courses_courseCode_unique" UNIQUE("courseCode")
);
--> statement-breakpoint
CREATE TABLE "department_level_courses" (
	"departmentId" uuid,
	"courseId" uuid,
	"level" integer NOT NULL,
	"review_status" "approval_status" DEFAULT 'pending',
	"reviewedBy" uuid,
	CONSTRAINT "department_level_courses_departmentId_courseId_pk" PRIMARY KEY("departmentId","courseId")
);
--> statement-breakpoint
CREATE TABLE "student_courses" (
	"userId" uuid,
	"courseId" uuid,
	CONSTRAINT "student_courses_userId_courseId_pk" PRIMARY KEY("userId","courseId")
);
--> statement-breakpoint
CREATE TABLE "material" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"type" "material_type" NOT NULL,
	"tags" text[],
	"click_count" integer DEFAULT 0,
	"view_count" integer DEFAULT 0,
	"download_count" integer DEFAULT 0,
	"likes" integer DEFAULT 0,
	"creator" uuid,
	"label" text,
	"description" text,
	"visibility" "visibility_enum" DEFAULT 'public',
	"restriction" "restriction_enum" DEFAULT 'readonly',
	"target_course" uuid,
	"review_status" "approval_status" DEFAULT 'pending',
	"reviewedBy" uuid,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "bookmarks" (
	"userId" uuid,
	"materialId" uuid,
	"collectionId" uuid,
	CONSTRAINT "bookmarks_userId_materialId_collectionId_pk" PRIMARY KEY("userId","materialId","collectionId")
);
--> statement-breakpoint
CREATE TABLE "collection" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"creator" uuid,
	"label" text NOT NULL,
	"description" text,
	"visibility" "visibility_enum" DEFAULT 'public'
);
--> statement-breakpoint
CREATE TABLE "collection_material" (
	"collectionId" uuid,
	"materialId" uuid,
	CONSTRAINT "collection_material_collectionId_materialId_pk" PRIMARY KEY("collectionId","materialId")
);
--> statement-breakpoint
CREATE TABLE "blogs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"creator" uuid NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"type" "blog_type" NOT NULL,
	"body" text NOT NULL,
	"likes" integer DEFAULT 0,
	"clicks" integer DEFAULT 0,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "comments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"blogId" uuid,
	"userId" uuid,
	"text" text NOT NULL,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "advert" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"type" "advert_type" NOT NULL,
	"amount" numeric,
	"material_id" uuid,
	"collection_id" uuid,
	"imageUrl" text NOT NULL,
	"label" text NOT NULL,
	"description" text,
	"clicks" integer DEFAULT 0,
	"impressions" integer DEFAULT 0,
	"review_status" "approval_status" DEFAULT 'pending',
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "resource" (
	"materialId" uuid PRIMARY KEY NOT NULL,
	"resourceAddress" text NOT NULL,
	"resourceType" "resource_type" NOT NULL,
	"fileKey" text,
	"metaData" text[],
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_department_department_id_fk" FOREIGN KEY ("department") REFERENCES "public"."department"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "auth" ADD CONSTRAINT "auth_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "moderator" ADD CONSTRAINT "moderator_userId_users_id_fk" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "moderator" ADD CONSTRAINT "moderator_department_department_id_fk" FOREIGN KEY ("department") REFERENCES "public"."department"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "moderator" ADD CONSTRAINT "moderator_faculty_faculty_id_fk" FOREIGN KEY ("faculty") REFERENCES "public"."faculty"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "department" ADD CONSTRAINT "department_facultyId_faculty_id_fk" FOREIGN KEY ("facultyId") REFERENCES "public"."faculty"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "courses" ADD CONSTRAINT "courses_reviewedBy_moderator_userId_fk" FOREIGN KEY ("reviewedBy") REFERENCES "public"."moderator"("userId") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "department_level_courses" ADD CONSTRAINT "department_level_courses_departmentId_department_id_fk" FOREIGN KEY ("departmentId") REFERENCES "public"."department"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "department_level_courses" ADD CONSTRAINT "department_level_courses_courseId_courses_id_fk" FOREIGN KEY ("courseId") REFERENCES "public"."courses"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "department_level_courses" ADD CONSTRAINT "department_level_courses_reviewedBy_moderator_userId_fk" FOREIGN KEY ("reviewedBy") REFERENCES "public"."moderator"("userId") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "student_courses" ADD CONSTRAINT "student_courses_userId_users_id_fk" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "student_courses" ADD CONSTRAINT "student_courses_courseId_courses_id_fk" FOREIGN KEY ("courseId") REFERENCES "public"."courses"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "material" ADD CONSTRAINT "material_creator_users_id_fk" FOREIGN KEY ("creator") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "material" ADD CONSTRAINT "material_target_course_courses_id_fk" FOREIGN KEY ("target_course") REFERENCES "public"."courses"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "material" ADD CONSTRAINT "material_reviewedBy_moderator_userId_fk" FOREIGN KEY ("reviewedBy") REFERENCES "public"."moderator"("userId") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_userId_users_id_fk" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_materialId_material_id_fk" FOREIGN KEY ("materialId") REFERENCES "public"."material"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_collectionId_collection_id_fk" FOREIGN KEY ("collectionId") REFERENCES "public"."collection"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection" ADD CONSTRAINT "collection_creator_users_id_fk" FOREIGN KEY ("creator") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection_material" ADD CONSTRAINT "collection_material_collectionId_collection_id_fk" FOREIGN KEY ("collectionId") REFERENCES "public"."collection"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "collection_material" ADD CONSTRAINT "collection_material_materialId_material_id_fk" FOREIGN KEY ("materialId") REFERENCES "public"."material"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "blogs" ADD CONSTRAINT "blogs_creator_users_id_fk" FOREIGN KEY ("creator") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "comments" ADD CONSTRAINT "comments_blogId_blogs_id_fk" FOREIGN KEY ("blogId") REFERENCES "public"."blogs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "comments" ADD CONSTRAINT "comments_userId_users_id_fk" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "advert" ADD CONSTRAINT "advert_material_id_material_id_fk" FOREIGN KEY ("material_id") REFERENCES "public"."material"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "advert" ADD CONSTRAINT "advert_collection_id_collection_id_fk" FOREIGN KEY ("collection_id") REFERENCES "public"."collection"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "resource" ADD CONSTRAINT "resource_materialId_material_id_fk" FOREIGN KEY ("materialId") REFERENCES "public"."material"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "users_email_index" ON "users" USING btree ("email");--> statement-breakpoint
CREATE INDEX "user_username_index" ON "users" USING btree ("username");--> statement-breakpoint
CREATE INDEX "auth_matric_no_index" ON "auth" USING btree ("matric_no");--> statement-breakpoint
CREATE INDEX "auth_email_index" ON "auth" USING btree ("email");