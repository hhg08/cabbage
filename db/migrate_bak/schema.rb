# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151010072824) do

  create_table "account_sets", force: :cascade do |t|
    t.string   "mapping_url",    limit: 255
    t.string   "bid_url",        limit: 255
    t.string   "win_notice_url", limit: 255
    t.integer  "qps",            limit: 4
    t.string   "no_cm_response", limit: 255
    t.string   "rtb_msg_format", limit: 255
    t.string   "use_tuserinfo",  limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "dsp_id",         limit: 4
  end

  create_table "expand_ad_originalities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expand_ads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expand_plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hq_adplan", id: false, force: :cascade do |t|
    t.integer "id",        limit: 4,                            default: 0,     null: false
    t.string  "name",      limit: 200
    t.decimal "day_limit",             precision: 12, scale: 2, default: 0.0,   null: false
    t.integer "addtime",   limit: 4,                            default: 0,     null: false
    t.string  "username",  limit: 200
    t.integer "company",   limit: 4,                            default: 0
    t.boolean "status",                                         default: false, null: false
    t.integer "adcount",   limit: 8
  end

  create_table "hq_auth_group", force: :cascade do |t|
    t.string  "title",    limit: 100,   default: "",   null: false
    t.boolean "status",                 default: true, null: false
    t.text    "rules",    limit: 65535,                null: false
    t.string  "describe", limit: 50,    default: "",   null: false
  end

  create_table "hq_auth_group_access", id: false, force: :cascade do |t|
    t.integer "uid",      limit: 3, null: false
    t.integer "group_id", limit: 3, null: false
  end

  add_index "hq_auth_group_access", ["group_id"], name: "group_id", using: :btree
  add_index "hq_auth_group_access", ["uid", "group_id"], name: "uid_group_id", unique: true, using: :btree
  add_index "hq_auth_group_access", ["uid"], name: "uid", using: :btree

  create_table "hq_auth_rule", force: :cascade do |t|
    t.string  "name",      limit: 80,  default: "",    null: false
    t.string  "title",     limit: 20,  default: "",    null: false
    t.boolean "type",                  default: true,  null: false
    t.boolean "status",                default: true,  null: false
    t.boolean "is_menu",               default: false, null: false
    t.boolean "is_first",              default: false, null: false
    t.string  "condition", limit: 100, default: "",    null: false
    t.integer "mid",       limit: 1,   default: 0,     null: false
  end

  add_index "hq_auth_rule", ["name"], name: "name", unique: true, using: :btree

  create_table "hq_baobiao", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_baobiao2", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                              default: 0,   null: false
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.text    "location",        limit: 65535
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.string  "tag_id",          limit: 100
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_baobiao3", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                              default: 0,   null: false
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.text    "location",        limit: 65535
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.string  "tag_id",          limit: 100
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_channel_baobiao", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.string  "channel_id",      limit: 100
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_channel_baobiao2", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.string  "channel_id",      limit: 100
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_channel_baobiao3", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.string  "channel_id",      limit: 100
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_channel_report", force: :cascade do |t|
    t.string   "client_id",  limit: 32,                           default: "0"
    t.integer  "group_id",   limit: 4,                            default: 0
    t.integer  "ad_id",      limit: 4,                            default: 0
    t.integer  "impression", limit: 4,                            default: 0,   null: false
    t.integer  "click",      limit: 4,                            default: 0,   null: false
    t.decimal  "cost",                   precision: 12, scale: 2, default: 0.0, null: false
    t.integer  "download",   limit: 4,                            default: 0,   null: false
    t.integer  "follow",     limit: 4,                            default: 0,   null: false
    t.integer  "install",    limit: 4,                            default: 0,   null: false
    t.integer  "active",     limit: 4,                            default: 0,   null: false
    t.boolean  "hour"
    t.date     "day"
    t.datetime "create_at",                                                     null: false
    t.string   "platform",   limit: 200
    t.string   "channel_id", limit: 100
  end

  create_table "hq_channel_reportlist", id: false, force: :cascade do |t|
    t.integer  "id",              limit: 4,                              default: 0,   null: false
    t.string   "client_id",       limit: 32,                             default: "0"
    t.integer  "group_id",        limit: 4,                              default: 0
    t.integer  "ad_id",           limit: 4,                              default: 0
    t.integer  "impression",      limit: 4,                              default: 0,   null: false
    t.integer  "click",           limit: 4,                              default: 0,   null: false
    t.decimal  "cost",                          precision: 12, scale: 2, default: 0.0, null: false
    t.integer  "download",        limit: 4,                              default: 0,   null: false
    t.integer  "follow",          limit: 4,                              default: 0,   null: false
    t.integer  "install",         limit: 4,                              default: 0,   null: false
    t.integer  "active",          limit: 4,                              default: 0,   null: false
    t.boolean  "hour"
    t.date     "day"
    t.datetime "create_at",                                                            null: false
    t.string   "platform",        limit: 200
    t.string   "channel_id",      limit: 100
    t.integer  "product",         limit: 4,                              default: 0
    t.text     "adname",          limit: 65535
    t.string   "shiduan",         limit: 1000
    t.integer  "company",         limit: 4,                              default: 0
    t.integer  "ad_start",        limit: 4,                              default: 0
    t.integer  "ad_end",          limit: 4,                              default: 0
    t.integer  "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal  "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal  "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
    t.integer  "plan",            limit: 4,                              default: 0
    t.string   "sex",             limit: 200,                            default: ""
    t.string   "age",             limit: 200,                            default: ""
  end

  create_table "hq_city", primary_key: "city_id", force: :cascade do |t|
    t.string  "city_name",     limit: 50, default: "", null: false
    t.integer "provincial_id", limit: 4,               null: false
    t.integer "indexNum",      limit: 4,  default: 0,  null: false
  end

  create_table "hq_company", force: :cascade do |t|
    t.string   "name",        limit: 200
    t.string   "tel",         limit: 200
    t.string   "address",     limit: 200
    t.string   "lxr",         limit: 200
    t.string   "lxrmobile",   limit: 200
    t.datetime "create_time",                                      default: '2000-01-01 00:00:00'
    t.decimal  "yue",                     precision: 12, scale: 2, default: 0.0
    t.decimal  "rxe",                     precision: 12, scale: 2, default: 1000.0
  end

  create_table "hq_consume", force: :cascade do |t|
    t.boolean "type",                                          default: false, null: false
    t.integer "company",  limit: 4,                            default: 0,     null: false
    t.decimal "money",                precision: 12, scale: 2, default: 0.0,   null: false
    t.string  "remark",   limit: 200
    t.integer "addtime",  limit: 4,                            default: 0,     null: false
    t.string  "username", limit: 200
  end

  create_table "hq_cost", force: :cascade do |t|
    t.integer "ad_id",                 limit: 4
    t.decimal "cost",                             precision: 11, scale: 2
    t.string  "day",                   limit: 11
    t.integer "hour",                  limit: 4
    t.integer "stage",                 limit: 4
    t.integer "ad_current_impression", limit: 4
    t.integer "ad_current_click",      limit: 4
  end

  create_table "hq_creative_baobiao", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_creative_baobiao2", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_creative_baobiao3", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_expand_ad", force: :cascade do |t|
    t.text    "name",              limit: 65535
    t.integer "plan",              limit: 4,                              default: 0,     null: false
    t.integer "ad_start",          limit: 4,                              default: 0,     null: false
    t.integer "ad_end",            limit: 4,                              default: 0,     null: false
    t.decimal "ad_cost",                         precision: 11, scale: 4, default: 0.0,   null: false
    t.boolean "ad_is_del",                                                default: false, null: false
    t.string  "shiduan",           limit: 1000,                                           null: false
    t.integer "product",           limit: 4,                              default: 0,     null: false
    t.string  "originality",       limit: 100,                            default: "0",   null: false
    t.integer "package",           limit: 4,                              default: 0,     null: false
    t.integer "addtime",           limit: 4,                              default: 0,     null: false
    t.integer "modifytime",        limit: 4,                                              null: false
    t.string  "username",          limit: 200
    t.integer "company",           limit: 4,                              default: 0
    t.boolean "status",                                                   default: false, null: false
    t.integer "checkstatus",       limit: 4,                              default: 0
    t.decimal "day_limit",                       precision: 11, scale: 2,                 null: false
    t.boolean "ad_billing_type",                                          default: false
    t.decimal "ad_cpm_price",                    precision: 11, scale: 2, default: 0.0
    t.integer "ad_cpm_count",      limit: 4,                              default: 0
    t.decimal "ad_cpc_price",                    precision: 11, scale: 2, default: 0.0
    t.integer "ad_cpc_count",      limit: 4,                              default: 0
    t.integer "plantform_tencent", limit: 4,                              default: 0
  end

  create_table "hq_expand_ad_exchange", force: :cascade do |t|
    t.integer "expand_id",    limit: 4,                                             null: false
    t.decimal "ad_cpm",                     precision: 11, scale: 2, default: 0.0,  null: false
    t.decimal "ad_rate",                    precision: 11, scale: 2, default: 30.0, null: false
    t.text    "ad_placement", limit: 65535,                                         null: false
    t.text    "ad_channel",   limit: 65535,                                         null: false
    t.string  "plantform",    limit: 200,                                           null: false
    t.boolean "type",                                                               null: false
    t.integer "company",      limit: 4,                                             null: false
  end

  create_table "hq_expand_ad_originality", id: false, force: :cascade do |t|
    t.integer "r_ad_id",          limit: 4, null: false
    t.integer "r_originality_id", limit: 4, null: false
  end

  create_table "hq_expand_plan", force: :cascade do |t|
    t.string  "name",      limit: 200
    t.decimal "day_limit",             precision: 12, scale: 2, default: 0.0,   null: false
    t.integer "addtime",   limit: 4,                            default: 0,     null: false
    t.string  "username",  limit: 200
    t.integer "company",   limit: 4,                            default: 0
    t.boolean "status",                                         default: false, null: false
    t.decimal "plan_cost",             precision: 12, scale: 2, default: 0.0,   null: false
  end

  create_table "hq_expands", id: false, force: :cascade do |t|
    t.integer "id",           limit: 4,     default: 0,     null: false
    t.text    "name",         limit: 65535
    t.integer "plan",         limit: 4,     default: 0,     null: false
    t.integer "ad_start",     limit: 4,     default: 0,     null: false
    t.integer "ad_end",       limit: 4,     default: 0,     null: false
    t.string  "shiduan",      limit: 1000,                  null: false
    t.integer "product",      limit: 4,     default: 0,     null: false
    t.string  "originality",  limit: 100,   default: "0",   null: false
    t.integer "package",      limit: 4,     default: 0,     null: false
    t.integer "addtime",      limit: 4,     default: 0,     null: false
    t.string  "username",     limit: 200
    t.integer "company",      limit: 4,     default: 0
    t.boolean "status",                     default: false, null: false
    t.integer "checkstatus",  limit: 4,     default: 0
    t.string  "plan_name",    limit: 200
    t.string  "product_name", limit: 200
    t.string  "ideal_name",   limit: 200
    t.string  "package_name", limit: 200,   default: ""
    t.boolean "planStatus",                 default: false
    t.boolean "ad_is_del",                  default: false, null: false
  end

  create_table "hq_geo_baobiao", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.string  "city_code",       limit: 100
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_geo_baobiao2", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.string  "city_code",       limit: 100
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_geo_baobiao3", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                              default: 0
    t.integer "group_id",        limit: 4,                              default: 0
    t.string  "client_id",       limit: 32,                             default: "0"
    t.integer "ad_id",           limit: 4,                              default: 0
    t.date    "day"
    t.boolean "hour"
    t.decimal "impression",                    precision: 32
    t.decimal "click",                         precision: 32
    t.decimal "download",                      precision: 32
    t.decimal "cost",                          precision: 34, scale: 2
    t.decimal "follow",                        precision: 32
    t.decimal "install",                       precision: 32
    t.decimal "active",                        precision: 32
    t.string  "platform",        limit: 200
    t.string  "city_code",       limit: 100
    t.integer "product",         limit: 4,                              default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "sex",             limit: 200,                            default: ""
    t.string  "age",             limit: 200,                            default: ""
    t.integer "company",         limit: 4,                              default: 0
    t.integer "ad_start",        limit: 4,                              default: 0
    t.integer "ad_end",          limit: 4,                              default: 0
    t.integer "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_geo_report", force: :cascade do |t|
    t.string   "client_id",  limit: 32,                           default: "0"
    t.integer  "group_id",   limit: 4,                            default: 0
    t.integer  "ad_id",      limit: 4,                            default: 0
    t.integer  "impression", limit: 4,                            default: 0,   null: false
    t.integer  "click",      limit: 4,                            default: 0,   null: false
    t.decimal  "cost",                   precision: 12, scale: 2, default: 0.0, null: false
    t.integer  "download",   limit: 4,                            default: 0,   null: false
    t.integer  "follow",     limit: 4,                            default: 0,   null: false
    t.integer  "install",    limit: 4,                            default: 0,   null: false
    t.integer  "active",     limit: 4,                            default: 0,   null: false
    t.boolean  "hour"
    t.date     "day"
    t.datetime "create_at",                                                     null: false
    t.string   "platform",   limit: 200
    t.string   "city_code",  limit: 100
  end

  create_table "hq_geo_reportlist", id: false, force: :cascade do |t|
    t.integer  "id",              limit: 4,                              default: 0,   null: false
    t.string   "client_id",       limit: 32,                             default: "0"
    t.integer  "group_id",        limit: 4,                              default: 0
    t.integer  "ad_id",           limit: 4,                              default: 0
    t.integer  "impression",      limit: 4,                              default: 0,   null: false
    t.integer  "click",           limit: 4,                              default: 0,   null: false
    t.decimal  "cost",                          precision: 12, scale: 2, default: 0.0, null: false
    t.integer  "download",        limit: 4,                              default: 0,   null: false
    t.integer  "follow",          limit: 4,                              default: 0,   null: false
    t.integer  "install",         limit: 4,                              default: 0,   null: false
    t.integer  "active",          limit: 4,                              default: 0,   null: false
    t.boolean  "hour"
    t.date     "day"
    t.datetime "create_at",                                                            null: false
    t.string   "platform",        limit: 200
    t.string   "city_code",       limit: 100
    t.integer  "product",         limit: 4,                              default: 0
    t.text     "adname",          limit: 65535
    t.string   "shiduan",         limit: 1000
    t.integer  "company",         limit: 4,                              default: 0
    t.integer  "ad_start",        limit: 4,                              default: 0
    t.integer  "ad_end",          limit: 4,                              default: 0
    t.integer  "plan",            limit: 4,                              default: 0
    t.integer  "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal  "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal  "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
    t.string   "sex",             limit: 200,                            default: ""
    t.string   "age",             limit: 200,                            default: ""
  end

  create_table "hq_leftmenu", id: false, force: :cascade do |t|
    t.integer "id",         limit: 3,   default: 0,     null: false
    t.string  "name",       limit: 80,  default: "",    null: false
    t.string  "title",      limit: 20,  default: "",    null: false
    t.boolean "type",                   default: true,  null: false
    t.boolean "status",                 default: true,  null: false
    t.boolean "is_menu",                default: false, null: false
    t.string  "condition",  limit: 100, default: "",    null: false
    t.integer "mid",        limit: 1,   default: 0,     null: false
    t.boolean "is_first",               default: false, null: false
    t.string  "moduleName", limit: 20,  default: ""
    t.integer "ord",        limit: 4,   default: 0
  end

  create_table "hq_manage_log", force: :cascade do |t|
    t.string  "module",   limit: 200,   null: false
    t.string  "action",   limit: 200,   null: false
    t.string  "url",      limit: 200,   null: false
    t.string  "username", limit: 200,   null: false
    t.integer "company",  limit: 4,     null: false
    t.integer "time",     limit: 4,     null: false
    t.string  "ip",       limit: 15,    null: false
    t.text    "raw_data", limit: 65535
    t.text    "new_data", limit: 65535
    t.text    "options",  limit: 65535
  end

  create_table "hq_modules", force: :cascade do |t|
    t.string  "moduleName", limit: 20,  default: "",    null: false
    t.string  "desc",       limit: 200,                 null: false
    t.boolean "is_menu",                default: false, null: false
    t.integer "ord",        limit: 4,   default: 0
  end

  create_table "hq_originality", force: :cascade do |t|
    t.string  "name",            limit: 200
    t.string  "guige",           limit: 200
    t.string  "source_type",     limit: 200
    t.string  "tags",            limit: 200
    t.string  "source",          limit: 200
    t.string  "target_url",      limit: 500
    t.string  "show_url",        limit: 200
    t.text    "third_part",      limit: 65535
    t.string  "username",        limit: 200
    t.integer "addtime",         limit: 4,     default: 0, null: false
    t.integer "company",         limit: 4,     default: 0
    t.integer "status_youku",    limit: 4,     default: 0, null: false
    t.integer "status_letv",     limit: 4,     default: 0, null: false
    t.integer "status_tencent",  limit: 4,     default: 0, null: false
    t.string  "url_letv",        limit: 400
    t.string  "url_youku",       limit: 400
    t.string  "url_tencent",     limit: 400
    t.string  "reason_youku",    limit: 200
    t.string  "reason_letv",     limit: 200
    t.string  "reason_tencent",  limit: 200
    t.integer "video_time",      limit: 4,     default: 0, null: false
    t.string  "click_track_url", limit: 500
  end

  create_table "hq_package", force: :cascade do |t|
    t.string  "name",     limit: 200,   default: ""
    t.string  "sex",      limit: 200,   default: ""
    t.string  "age",      limit: 200,   default: ""
    t.string  "system",   limit: 200,   default: ""
    t.string  "lianwang", limit: 200,   default: ""
    t.text    "location", limit: 65535
    t.text    "desc",     limit: 65535
    t.integer "addtime",  limit: 4,     default: 0,  null: false
    t.string  "username", limit: 100,   default: ""
    t.integer "company",  limit: 4,     default: 0
  end

  create_table "hq_plan", id: false, force: :cascade do |t|
    t.integer "id",          limit: 4,                              default: 0,      null: false
    t.text    "name",        limit: 65535
    t.integer "plan",        limit: 4,                              default: 0,      null: false
    t.integer "ad_start",    limit: 4,                              default: 0,      null: false
    t.integer "ad_end",      limit: 4,                              default: 0,      null: false
    t.string  "shiduan",     limit: 1000,                                            null: false
    t.integer "product",     limit: 4,                              default: 0,      null: false
    t.string  "originality", limit: 100,                            default: "0",    null: false
    t.integer "package",     limit: 4,                              default: 0,      null: false
    t.integer "addtime",     limit: 4,                              default: 0,      null: false
    t.string  "username",    limit: 200
    t.integer "company",     limit: 4,                              default: 0
    t.decimal "cost",                      precision: 12, scale: 2, default: 0.0
    t.decimal "day_limit",                 precision: 12, scale: 2, default: 0.0
    t.decimal "rxe",                       precision: 12, scale: 2, default: 1000.0
    t.boolean "planStatus",                                         default: false
  end

  create_table "hq_product", force: :cascade do |t|
    t.string  "name",          limit: 200
    t.string  "game_type",     limit: 100
    t.string  "child_type",    limit: 100
    t.string  "huamian_type",  limit: 100
    t.string  "huamian_style", limit: 100
    t.string  "game_subject",  limit: 100
    t.integer "addtime",       limit: 4,   default: 0, null: false
    t.string  "username",      limit: 100
    t.integer "company",       limit: 4,   default: 0
  end

  create_table "hq_provincial", primary_key: "provincial_id", force: :cascade do |t|
    t.string "provincial_name", limit: 50
  end

  create_table "hq_report", force: :cascade do |t|
    t.string   "client_id",   limit: 32,                           default: "0"
    t.integer  "group_id",    limit: 4,                            default: 0
    t.integer  "ad_id",       limit: 4,                            default: 0
    t.integer  "creative_id", limit: 4,                            default: 0,   null: false
    t.integer  "impression",  limit: 4,                            default: 0,   null: false
    t.integer  "click",       limit: 4,                            default: 0,   null: false
    t.decimal  "cost",                    precision: 12, scale: 2, default: 0.0, null: false
    t.integer  "download",    limit: 4,                            default: 0,   null: false
    t.integer  "follow",      limit: 4,                            default: 0,   null: false
    t.integer  "install",     limit: 4,                            default: 0,   null: false
    t.integer  "active",      limit: 4,                            default: 0,   null: false
    t.boolean  "hour"
    t.date     "day"
    t.datetime "create_at",                                                      null: false
    t.string   "platform",    limit: 200
    t.string   "tag_id",      limit: 100
  end

  create_table "hq_reportlist", id: false, force: :cascade do |t|
    t.integer  "id",              limit: 4,                              default: 0,   null: false
    t.string   "client_id",       limit: 32,                             default: "0"
    t.integer  "group_id",        limit: 4,                              default: 0
    t.integer  "ad_id",           limit: 4,                              default: 0
    t.integer  "creative_id",     limit: 4,                              default: 0,   null: false
    t.integer  "impression",      limit: 4,                              default: 0,   null: false
    t.integer  "click",           limit: 4,                              default: 0,   null: false
    t.decimal  "cost",                          precision: 12, scale: 2, default: 0.0, null: false
    t.integer  "download",        limit: 4,                              default: 0,   null: false
    t.integer  "follow",          limit: 4,                              default: 0,   null: false
    t.integer  "install",         limit: 4,                              default: 0,   null: false
    t.integer  "active",          limit: 4,                              default: 0,   null: false
    t.boolean  "hour"
    t.date     "day"
    t.datetime "create_at",                                                            null: false
    t.string   "platform",        limit: 200
    t.string   "tag_id",          limit: 100
    t.integer  "product",         limit: 4,                              default: 0
    t.text     "adname",          limit: 65535
    t.string   "shiduan",         limit: 1000
    t.integer  "company",         limit: 4,                              default: 0
    t.integer  "ad_start",        limit: 4,                              default: 0
    t.integer  "ad_end",          limit: 4,                              default: 0
    t.integer  "plan",            limit: 4,                              default: 0
    t.integer  "ad_billing_type", limit: 4,                              default: 0,   null: false
    t.decimal  "ad_cpm_price",                  precision: 11, scale: 2, default: 0.0
    t.decimal  "ad_cpc_price",                  precision: 11, scale: 2, default: 0.0
    t.string   "sex",             limit: 200,                            default: ""
    t.string   "age",             limit: 200,                            default: ""
    t.text     "location",        limit: 65535
  end

  create_table "hq_session", id: false, force: :cascade do |t|
    t.string  "session_id",      limit: 255, null: false
    t.integer "session_expires", limit: 4,   null: false
    t.string  "session_data",    limit: 255
  end

  add_index "hq_session", ["session_id"], name: "session_id", unique: true, using: :btree

  create_table "hq_tag", primary_key: "tag_id", force: :cascade do |t|
    t.string "name", limit: 30, default: "", null: false
  end

  create_table "hq_tag_baobiao", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_tag_baobiao2", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_tag_baobiao3", id: false, force: :cascade do |t|
    t.integer "plan",            limit: 4,                                   default: 0
    t.integer "group_id",        limit: 4,                                   default: 0
    t.string  "client_id",       limit: 32,                                  default: "0"
    t.integer "ad_id",           limit: 4,                                   default: 0
    t.date    "day"
    t.boolean "hour"
    t.integer "creative_id",     limit: 4,                                   default: 0,   null: false
    t.decimal "impression",                         precision: 32
    t.decimal "click",                              precision: 32
    t.decimal "download",                           precision: 32
    t.decimal "cost",                               precision: 34, scale: 2
    t.decimal "follow",                             precision: 32
    t.decimal "install",                            precision: 32
    t.decimal "active",                             precision: 32
    t.string  "platform",        limit: 200
    t.integer "product",         limit: 4,                                   default: 0
    t.text    "adname",          limit: 65535
    t.string  "shiduan",         limit: 1000
    t.string  "tag_id",          limit: 100
    t.string  "sex",             limit: 200,                                 default: ""
    t.string  "age",             limit: 200,                                 default: ""
    t.text    "location",        limit: 4294967295
    t.integer "company",         limit: 4,                                   default: 0
    t.integer "ad_start",        limit: 4,                                   default: 0
    t.integer "ad_end",          limit: 4,                                   default: 0
    t.integer "ad_billing_type", limit: 4,                                   default: 0,   null: false
    t.decimal "ad_cpm_price",                       precision: 11, scale: 2, default: 0.0
    t.decimal "ad_cpc_price",                       precision: 11, scale: 2, default: 0.0
  end

  create_table "hq_tag_relation", id: false, force: :cascade do |t|
    t.integer "tag_id",            limit: 4,               null: false
    t.integer "parent_id",         limit: 4,               null: false
    t.string  "tag_relation_type", limit: 20, default: "", null: false
  end

  create_table "hq_track_originality", force: :cascade do |t|
    t.integer "expand_id",      limit: 4
    t.string  "name",           limit: 200
    t.string  "target_url",     limit: 500
    t.string  "impression_url", limit: 500
    t.string  "click_url",      limit: 500
    t.string  "username",       limit: 200
    t.integer "addtime",        limit: 4,   default: 0, null: false
    t.integer "company",        limit: 4,   default: 0
  end

  create_table "hq_tracking_report", force: :cascade do |t|
    t.integer "client_id",   limit: 4, default: 0
    t.integer "group_id",    limit: 4, default: 0
    t.integer "ad_id",       limit: 4, default: 0
    t.integer "creative_id", limit: 4, default: 0
    t.integer "impression",  limit: 4, default: 0
    t.integer "click",       limit: 4, default: 0
    t.integer "hour",        limit: 4
    t.date    "day"
  end

  create_table "hq_trackinglist", id: false, force: :cascade do |t|
    t.integer "id",          limit: 4,     default: 0, null: false
    t.integer "client_id",   limit: 4,     default: 0
    t.integer "group_id",    limit: 4,     default: 0
    t.integer "ad_id",       limit: 4,     default: 0
    t.integer "creative_id", limit: 4,     default: 0
    t.integer "impression",  limit: 4,     default: 0
    t.integer "click",       limit: 4,     default: 0
    t.integer "hour",        limit: 4
    t.date    "day"
    t.integer "product",     limit: 4,     default: 0
    t.text    "adname",      limit: 65535
    t.integer "company",     limit: 4,     default: 0
    t.string  "planname",    limit: 200
  end

  create_table "hq_trackinglist2", id: false, force: :cascade do |t|
    t.integer "id",          limit: 4,     default: 0, null: false
    t.integer "client_id",   limit: 4,     default: 0
    t.integer "group_id",    limit: 4,     default: 0
    t.integer "ad_id",       limit: 4,     default: 0
    t.integer "creative_id", limit: 4,     default: 0
    t.integer "impression",  limit: 4,     default: 0
    t.integer "click",       limit: 4,     default: 0
    t.integer "hour",        limit: 4
    t.date    "day"
    t.integer "product",     limit: 4,     default: 0
    t.text    "adname",      limit: 65535
    t.integer "company",     limit: 4,     default: 0
    t.string  "planname",    limit: 200
    t.string  "originname",  limit: 200
  end

  create_table "hq_userlist", id: false, force: :cascade do |t|
    t.integer  "uid",             limit: 3,   default: 0,    null: false
    t.string   "username",        limit: 20,  default: "",   null: false
    t.string   "password",        limit: 32,  default: "",   null: false
    t.string   "nicename",        limit: 200, default: "",   null: false
    t.boolean  "user_status",                 default: true, null: false
    t.integer  "company",         limit: 4,   default: 0,    null: false
    t.string   "last_login_ip",   limit: 16,  default: "",   null: false
    t.datetime "last_login_time"
    t.datetime "create_time",                                null: false
    t.integer  "group_id",        limit: 3
    t.string   "companyname",     limit: 200
  end

  create_table "hq_users", primary_key: "uid", force: :cascade do |t|
    t.string   "username",        limit: 20,    default: "",   null: false
    t.string   "password",        limit: 32,    default: "",   null: false
    t.string   "nicename",        limit: 200,   default: "",   null: false
    t.boolean  "user_status",                   default: true, null: false
    t.integer  "company",         limit: 4,     default: 0,    null: false
    t.text     "company_manager", limit: 65535,                null: false
    t.string   "last_login_ip",   limit: 16,    default: "",   null: false
    t.datetime "last_login_time"
    t.datetime "create_time",                                  null: false
  end

  create_table "originalities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "dsp_order_id", limit: 255
    t.string   "date",         limit: 255
    t.string   "lid",          limit: 255
    t.integer  "bid",          limit: 4
    t.integer  "suc_bid",      limit: 4
    t.integer  "pv",           limit: 4
    t.integer  "click",        limit: 4
    t.integer  "amount",       limit: 4
  end

  create_table "tencent_ad_lists", force: :cascade do |t|
    t.string   "tag_id",         limit: 255
    t.string   "tag_name",       limit: 255
    t.integer  "width",          limit: 4
    t.integer  "height",         limit: 4
    t.decimal  "min_cpm",                      precision: 10
    t.text     "block_vacation", limit: 65535
    t.text     "allow_file",     limit: 65535
    t.string   "enable",         limit: 255
    t.string   "screen",         limit: 255
    t.string   "review_pic",     limit: 255
    t.string   "tag_quality",    limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
