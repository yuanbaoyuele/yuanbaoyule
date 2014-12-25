#include "stdafx.h"
#include "boost/regex.hpp"
#include "FilterManager.h"
#include <fstream>
#include "ADBFilter.h"
#include <string.h>


struct FilterRuleList {
	FilterRule * r;
	FilterRuleList * next;
    inline bool doFilter(const Url & mainURL,const Url & url, FilterType t) {
		FilterRuleList * l = this;
		while (l) {
            if (l->r->shouldFilter(mainURL,url,t))
				return true;
			l = l->next;
		}
		return false;
	}
};

struct ReplaceRuleList {
	ReplaceRule * r;
	ReplaceRuleList * next;
	inline void getRelpace(const Url & url,std::vector<std::string> &v_Parse) {
		ReplaceRuleList * l = this;
		while (l) {
			if (l->r->shouldReplace(url))
				v_Parse.push_back(l->r->getReplace());
			l = l->next;
		}
		return ;
	}
};



#define RULE_KEY_HASH_LENGTH 8
inline int abpmin(int f1,int f2)
{
    return f1<f2?f1:f2;
}

static bool collectShortcuts(const std::string & str, StringVector & vs) 
{
	static boost::unordered_set<std::string> commonFilters;
	if(commonFilters.empty()) {
#if RULE_KEY_HASH_LENGTH==7 // 7
		commonFilters.insert("http://");
		commonFilters.insert("ttp://w");
		commonFilters.insert("tp://ww");
		commonFilters.insert("p://www");
		commonFilters.insert("://www.");
#elif RULE_KEY_HASH_LENGTH==8 // 8
		commonFilters.insert("http://w");
		commonFilters.insert("ttp://ww");
		commonFilters.insert("tp://www");
		commonFilters.insert("p://www.");
#elif RULE_KEY_HASH_LENGTH==9 // 9
		commonFilters.insert("http://ww");
		commonFilters.insert("ttp://www");
		commonFilters.insert("tp://www.");
#endif
	}

	int i = 0;
	bool isFindShoutcut = false;
	while (i < abpmin(str.length() - RULE_KEY_HASH_LENGTH,80)) 
	{
		unsigned int j = i;
		for (; j < str.length(); j++) {
			if ((str[j] == '*' || str[j] == '^'))
			{
				break;
			}
		}
		for (unsigned int k = i; j - k >= RULE_KEY_HASH_LENGTH; k++) 
		{
			std::string key = str.substr(k, RULE_KEY_HASH_LENGTH);
			if(commonFilters.find(key)!=commonFilters.end())
				continue;
			isFindShoutcut = true;
			vs.push_back(key); //append(key);
		}
		i = j + 1;
	}
	return isFindShoutcut;
}

bool RuleMap::FilterRuleMap::doFilter(const Url & mainURL,const std::string &key, const Url & url,FilterType t) {
	FilterRuleMap::iterator mapit=find(key);
	if (mapit != end()) {
		unsigned int address = (unsigned int) mapit->second;
		if (unMatchRules.find(address) != unMatchRules.end()) // already match this rules;
			return false;
		this->unMatchRules.insert(address);  //add(address)
		if (mapit->second->doFilter(mainURL, url, t))
			return true;
	}
	return false;
}

RuleMap::FilterRuleMap::~FilterRuleMap() {
	for (FilterRuleMap::iterator it = this->begin(); it != this->end(); ++it) {
		FilterRuleList * l = it->second;
		FilterRuleList * n = l->next;
		while (n) {
			FilterRuleList * temp = n->next;
			delete n;
			n = temp;
		}
		delete l;
	}
}


void RuleMap::ReplaceRuleMap::getReplace(const std::string &key,const Url & url,std::vector<std::string> &v_Parse) {
	ReplaceRuleMap::iterator mapit=find(key);
	if (mapit != end())
	{
		unsigned int address = (unsigned int) mapit->second;
		if (unMatchRules.find(address) != unMatchRules.end()) // already match this rules;
			return ;
		this->unMatchRules.insert(address);  //add(address)
		mapit->second->getRelpace(url,v_Parse);
	}
	return ;
}

RuleMap::ReplaceRuleMap::~ReplaceRuleMap() {
	for (ReplaceRuleMap::iterator it = this->begin(); it != this->end(); ++it) 
	{
		ReplaceRuleList * l = it->second;
		ReplaceRuleList * n = l->next;
		while (n) 
		{
			ReplaceRuleList * temp = n->next;
			delete n;
			n = temp;
		}
		delete l;
	}
}

RuleMap::~RuleMap()
{
	for (FilterRuleVector::iterator it=m_AllFilterRules.begin();
		it!=m_AllFilterRules.end();++it) {
			delete *it;
	}

	for (ReplaceRuleVector::iterator it=m_AllReplaceRules.begin();
		it!=m_AllReplaceRules.end();++it) {
			delete *it;
	}
}

void RuleMap::insertRuleToFilterRuleMap(FilterRuleMap * rules,const std::string & key, FilterRule * r)
{
	FilterRuleMap::iterator it = rules->find(key);
	if (it != rules->end()) { // already exists
		FilterRuleList * l = it->second;
		while (l->next)
			l = l->next;
		FilterRuleList * n = new FilterRuleList();
		n->r = r;
		n->next = NULL;
		l->next = n;
	} else {
		FilterRuleList * n = new FilterRuleList();
		n->r = r;
		n->next = NULL;
		rules->insert(FilterRuleMap::value_type(key, n)); //add(key, n)
	}
}

void RuleMap::addRule(FilterRule * r)
{
	this->m_AllFilterRules.push_back(r); //for delete FilterRule;
	FilterRuleMap * rules;
	FilterRuleVector * unshortcutRules;
	StringVector domains;
	r->getDomains(domains);
	if (r->isWhiteFilter())
	{
		rules = domains.empty()?&m_ShortcutWhiteRules:&m_DomainWhiteRules;
		unshortcutRules = &m_UnshortcutWhiteRules;
	}
	else 
	{
		rules = domains.empty() ? &m_ShortcutFilterRules : &m_DomainFilterRules;
		unshortcutRules = &m_UnshortcutFilterRules;
	}
	if(!domains.empty()) 
	{
		for(UINT i=0;i<domains.size();i++) 
		{
			insertRuleToFilterRuleMap(rules,domains[i],r);
		}
		return;
	}
	/*
	 * 没有域名信息才会进行8个字符8个字符的索引
	 */
	const std::string & reFilter = r->getRegularFilter();
	StringVector shortcuts;
	if (collectShortcuts(reFilter, shortcuts)) 
	{
		unsigned int i = 0;
		for (; i < shortcuts.size(); i++) 
		{
			insertRuleToFilterRuleMap(rules,shortcuts[i],r);
		}
	} 
	else
		unshortcutRules->push_back(r);//append(r);
}

void RuleMap::insertRuleToFilterRuleMap(ReplaceRuleMap * rules,const std::string & key, ReplaceRule * r)
{
	ReplaceRuleMap::iterator it = rules->find(key);
	if (it != rules->end())
	{ // already exists
		ReplaceRuleList * l = it->second;
		while (l->next)
			l = l->next;
		ReplaceRuleList * n = new ReplaceRuleList();
		n->r = r;
		n->next = NULL;
		l->next = n;
	}
	else 
	{
		ReplaceRuleList * n = new ReplaceRuleList();
		n->r = r;
		n->next = NULL;
		rules->insert(ReplaceRuleMap::value_type(key, n)); //add(key, n)
	}
}

void RuleMap::addRule(ReplaceRule * r)
{
	this->m_AllReplaceRules.push_back(r); 
	ReplaceRuleMap * rules = &m_DomainReplaceRules;

	std::string domain;
	r->getDomains(domain);
	if(!domain.empty()) 
	{
		insertRuleToFilterRuleMap(rules,domain,r);
		return;
	}
}

bool RuleMap::shouldFilterByDomain(const Url & mainURL,const Url & url,FilterType t,bool & isFind)
{
	StringVector dotsplits;
	this->m_DomainFilterRules.prepareStartFind();
	this->m_DomainWhiteRules.prepareStartFind();
	boost::split(dotsplits,url.GetHost(),boost::is_any_of("."));
	if (dotsplits.size() <= 1) //domain error? no dot? at least g.cn
		return false;
	for (int i = dotsplits.size() - 2; i >= 0; i--) {
		std::string domain = dotsplits[i];
		for (int j = i + 1; j < dotsplits.size(); j++) {
			domain = domain + "." + dotsplits[j];
		}
		isFind=m_DomainWhiteRules.doFilter(mainURL, domain, url, t);
		if (isFind)
			return false;
		isFind=m_DomainFilterRules.doFilter(mainURL, domain, url, t);
		if (isFind)
			return true;
	}
	return false;
}

bool RuleMap::shouldFilterByShortcut(const Url & mainURL,const Url & url,FilterType t)
{
	StringVector shortcuts;
	collectShortcuts(url.GetString(), shortcuts);
	this->m_ShortcutFilterRules.prepareStartFind();
	for (StringVector::iterator it = shortcuts.begin(); it != shortcuts.end(); ++it) {
		if (m_ShortcutWhiteRules.doFilter(mainURL, *it, url, t))
			return false;
	}
	for (FilterRuleVector::iterator it =
		this->m_UnshortcutWhiteRules.begin(); it
		!= this->m_UnshortcutWhiteRules.end(); ++it) {
			if ((*it)->shouldFilter(mainURL, url, t))
				return false;
	}
	for (StringVector::iterator it = shortcuts.begin(); it != shortcuts.end(); ++it) {
		if (this->m_ShortcutFilterRules.doFilter(mainURL, *it, url, t))
			return true;
	}
	for (FilterRuleVector::iterator it = this->m_UnshortcutFilterRules.begin(); it != this->m_UnshortcutFilterRules.end(); ++it) 
	{
		if ((*it)->shouldFilter(mainURL, url, t))
			return true;
	}
	return false;
}

bool RuleMap::shouldFilter(const Url & mainURL,const Url & url,FilterType t)
{
	bool bFind =false;
	bool bRet = shouldFilterByDomain(mainURL,url,t,bFind);
	if(!bFind)
		bRet = shouldFilterByShortcut(mainURL,url,t);
	return bRet;
}

void RuleMap::getreplaceRules(const Url & url,std::vector<std::string> & v_replace)
{
	StringVector dotsplits;
	this->m_DomainReplaceRules.prepareStartFind();

	boost::split(dotsplits,url.GetHost(),boost::is_any_of("."));
	if (dotsplits.size() >= 1) //domain error? no dot? at least g.cn
	{
		for (int i = dotsplits.size() - 2; i >= 0; i--) 
		{
			std::string domain = dotsplits[i];
			for (int j = i + 1; j < dotsplits.size(); j++) 
			{
				domain = domain + "." + dotsplits[j];
			}
			m_DomainReplaceRules.getReplace(domain,url,v_replace);
		}
	}
}

static FilterManager * m=NULL;

FilterManager * FilterManager::getManager()
{
	if(NULL == m)
		m = new FilterManager;
	return m;
}

bool FilterManager::getVideoRules(const std::wstring & filename)
{
	return getRules(filename,FILE_RULE_VIDEO);
}

bool FilterManager::getRules(const std::wstring & filename,int ruleType)
{
	RuleMap * pRuleMap = &m_VideoRules;	
	ifstream infile(filename.c_str());
	if (!infile)
	{ 
		return false;
	}
	else 
	{
		char rule[1000];
		infile.getline(rule, 1000); //忽略第一行版本号

		std::string strMatch = ".*\\$s@.*@.*@.*";
		boost::regex expression(strMatch);
		while (!infile.eof())
		{
			memset(rule, 0, 1000);
			infile.getline(rule, 1000);
			if (rule[0] == '!')
			{
				//行注释
			}
			else
			{
				int n = strlen(rule);
				if (rule[n - 1] == '\n' || rule[n - 1] == '\r') {
					rule[n - 1] = '\0';
				}
				if (rule[n - 2] == '\n' || rule[n - 2] == '\r') {
					rule[n - 2] = '\0';
				} 
				if (strlen(rule) <= 3) //too short rule ,maybe some error
					continue;
				std::string s(rule); 
				if (boost::regex_match(s, expression))
				{
					pRuleMap->addRule(new ReplaceRule(s));
				}
				else 
				{
					pRuleMap->addRule(new FilterRule(s));
				}
			}
		}
	}
	return true;
}

bool FilterManager::shouldFilter(const Url & mainURL,const Url & url, FilterType t)
{
	return m_VideoRules.shouldFilter(mainURL,url,t);
}

void FilterManager::getreplaceRules(const Url & url,std::vector<std::string> & v_replace)
{
    m_VideoRules.getreplaceRules(url,v_replace);	
	return;
}

std::string FilterManager::getcssRules(const Url & url)
{
	std::string res;
	return res;
}