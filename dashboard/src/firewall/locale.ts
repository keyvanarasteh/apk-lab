export type FirewallLocale = "en" | "tr";

import type { BranchRole, FirewallAction, RuleDirection } from "./types";

const roles: Record<BranchRole, string> = {
  headquarters: "genel merkez", branch: "şube", campus: "kampüs", datacenter: "veri merkezi", remote: "uzak ofis"
};
const actions: Record<FirewallAction, string> = {
  allow: "izin ver", deny: "engelle", reject: "reddet", limit: "sınırla"
};
const directions: Record<RuleDirection, string> = { in: "gelen", out: "giden", forward: "iletilen" };
const statuses: Record<string, string> = {
  patched: "yamalandı", "not-affected": "etkilenmiyor", investigating: "inceleniyor", vulnerable: "savunmasız", mitigated: "önlem alındı"
};

export const branchRole = (role: BranchRole, locale: FirewallLocale) => locale === "tr" ? roles[role] : role;
export const ruleAction = (action: FirewallAction, locale: FirewallLocale) => locale === "tr" ? actions[action] : action;
export const ruleDirection = (direction: RuleDirection, locale: FirewallLocale) => locale === "tr" ? directions[direction] : direction;
export const cveStatus = (status: string, locale: FirewallLocale) => locale === "tr" ? (statuses[status] ?? status) : status;

export const firewallPath = (locale: FirewallLocale, slug?: string) =>
  `${locale === "tr" ? "/tr/firewall/" : "/firewall/"}${slug ? `${slug}/` : ""}`;

export const copy = {
  en: {
    lab: "Firewall Lab", add: "Add your company", contribute: "How to contribute",
    intro: "BGT207 — design your dream company's network and firewalls: branches, VLAN segmentation, bandwidth, the best five products per segment (with price), and a rule set you can explain line by line. Every company here arrived as a pull request.",
    contributeHint: "Copy firewall-lab/templates/company, fill company.json, validate, and open a PR.",
    companies: "Companies", empty: "No companies yet — be the first to open a PR.",
    explore: "Explore the network & its gaps", companyViews: "Company views", network: "Network", gaps: "Gaps", branches: "Branches", people: "People", firewalls: "Firewalls", rules: "Rules",
    person: "people", firewall: "firewall", rule: "rule", linkDrivers: "Link drivers", alternatives: "alternatives considered",
    show: "Show", hide: "Hide", ruleSet: "Rule set · first match wins", from: "from", any: "any",
    remote: "Remote access & monitoring", owner: "Owner", alerts: "Alerts land in", appSecurity: "App vs. security monitoring",
    cve: "CVE watch", noCve: "No CVEs tracked (optional / bonus). A perimeter firewall can't stop an app-layer bug anyway — that's a WAF-and-patch job.",
    allCompanies: "All companies", companyNetwork: "Company network", overview: "Overview", branchComposition: "Branch composition",
    selectBranch: "Select a branch to inspect its design", selectedBranch: "Selected branch", connection: "Connection",
    networkSegments: "Network segments", dmzPresent: "DMZ present", internalNetwork: "Internal network",
    segmentedNetwork: "Segmented network", firewallLayers: "Firewall layers", totalRules: "rules total",
    allDesigns: "All company designs", next: "Next", networkDetails: "network details",
    description: "Student company network and firewall designs (BGT207).",
    companyDescription: "branches, VLANs, firewalls and rule sets in the os-lab firewall lab."
  },
  tr: {
    lab: "Güvenlik Duvarı Laboratuvarı", add: "Şirketini ekle", contribute: "Nasıl katkıda bulunulur?",
    intro: "BGT207 — hayalindeki şirketin ağını ve güvenlik duvarlarını tasarla: şubeler, VLAN bölümlendirmesi, bant genişliği, her ağ bölümü için fiyatlarıyla en iyi beş ürün ve satır satır açıklayabileceğin kural kümesi. Buradaki her şirket bir pull request ile eklendi.",
    contributeHint: "firewall-lab/templates/company şablonunu kopyala, company.json dosyasını doldur, doğrula ve bir PR aç.",
    companies: "Şirketler", empty: "Henüz şirket yok — ilk PR'ı sen aç.",
    explore: "Ağı ve açıklarını incele", companyViews: "Şirket görünümleri", network: "Ağ", gaps: "Açıklar", branches: "Şubeler", people: "Kişi", firewalls: "Güvenlik duvarları", rules: "Kurallar",
    person: "kişi", firewall: "güvenlik duvarı", rule: "kural", linkDrivers: "Bağlantı gereksinimleri", alternatives: "alternatif değerlendirildi",
    show: "Göster", hide: "Gizle", ruleSet: "Kural kümesi · ilk eşleşen kural uygulanır", from: "kaynak", any: "tümü",
    remote: "Uzaktan erişim ve izleme", owner: "Sorumlu", alerts: "Uyarıların hedefi", appSecurity: "Uygulama ve güvenlik izlemesi",
    cve: "CVE takibi", noCve: "Takip edilen CVE yok (isteğe bağlı / ek çalışma). Çevre güvenlik duvarı uygulama katmanındaki bir açığı tek başına durduramaz; bunun için WAF ve yama gerekir.",
    allCompanies: "Tüm şirketler", companyNetwork: "Şirket ağı", overview: "Genel bakış", branchComposition: "Şube yapısı",
    selectBranch: "Tasarımını incelemek için bir şube seç", selectedBranch: "Seçili şube", connection: "Bağlantı",
    networkSegments: "Ağ bölümleri", dmzPresent: "DMZ mevcut", internalNetwork: "İç ağ",
    segmentedNetwork: "Bölümlendirilmiş ağ", firewallLayers: "Güvenlik duvarı katmanları", totalRules: "toplam kural",
    allDesigns: "Tüm şirket tasarımları", next: "Sonraki", networkDetails: "ağ ayrıntıları",
    description: "Öğrenci şirketlerinin ağ ve güvenlik duvarı tasarımları (BGT207).",
    companyDescription: "os-lab güvenlik duvarı laboratuvarındaki şubeler, VLAN'lar, güvenlik duvarları ve kural kümeleri."
  }
} as const;
