#ifndef JSONSERIALIZABLE_H
#define JSONSERIALIZABLE_H

#include <QVariant>
#include <QJsonObject>

class JsonSerializable
{

public:

    explicit JsonSerializable();
     JsonSerializable(const QJsonObject& jsonObject);
    ~JsonSerializable();

    void setProperty(const QString& name, QVariant value = QVariant());
    void setProperties(const QVariantMap& props);
    QVariant property(const QString& name) const;
    QVariantMap& properties();
    void addChild(const QString& name);
    void addChild(JsonSerializable* child);
    void replaceChild(JsonSerializable* child, JsonSerializable* newChild);
    void addChild();
    void removeChild(const QString& name);
    void renameChild(const QString& name, const QString& newName);

    JsonSerializable* getChild(const QString& name) const;
    QStringList childrenNames() const;
    int listedChildrenCount() const;
    QList<JsonSerializable*> listedChildren() const;
    QMap<QString, JsonSerializable*> namedChildren() const;

    QJsonObject toJsonObject() const;
    void fromJsonObject(const QJsonObject& jsonObject);

    void clear();
    bool isEmpty() const;

protected:

    void cleanChildren();

private:

    QVariantMap _properties;
    QMap<QString, JsonSerializable*> _namedChildren;
    QList<JsonSerializable*> _childrenList;

};

#endif // JSONSERIALIZABLE_H
